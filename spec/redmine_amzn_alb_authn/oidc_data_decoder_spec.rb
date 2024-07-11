# frozen_string_literal: true

RSpec.describe RedmineAmznAlbAuthn::OidcDataDecoder do
  subject(:decoder) { described_class.new(key_endpoint: 'https://example.com', alb_arn:, iss: expected_iss) }

  let(:alb_arn) { 'arn:aws:elasticloadbalancing:ap-northeast-1:012345678901:loadbalancer/app/my-alb/0123456789abcdef' }
  let(:expected_iss) { 'https://iss.example.com' }

  describe '#verify_and_decode!' do
    let(:oidc_data) do
      JWT.encode({ sub: 1, exp: 2.minutes.from_now.to_i, iss: }, private_key, 'ES256', kid:, signer:)
    end
    let(:iss) { expected_iss }
    let(:signer) { alb_arn }
    let(:kid) { SecureRandom.uuid }
    let(:private_key) { OpenSSL::PKey::EC.generate('prime256v1') }

    before do
      stub_request(:get, "https://example.com/#{kid}")
        .to_return(body: private_key.public_to_pem)
    end

    it 'returns a payload and a header' do
      payload, header = decoder.verify_and_decode!(oidc_data)

      expect(payload).to include 'exp', 'sub' => 1
      expect(header).to include 'kid', 'signer', 'alg' => 'ES256'
    end

    context 'with a payload-modified JWT' do
      let(:oidc_data) do
        jwt = JWT.encode({ sub: 1, exp: 2.minutes.from_now.to_i }, private_key, 'ES256', kid:, signer:)
        header, _payload, signature = jwt.split('.')
        modified_payload = JWT::Base64.url_encode({ sub: 'modified' }.to_json)
        "#{header}.#{modified_payload}.#{signature}"
      end

      it 'raises JWT::VerificationError' do
        expect { decoder.verify_and_decode!(oidc_data) }.to raise_error(JWT::VerificationError)
      end
    end

    context 'with a JWT that has unexpected iss' do
      let(:iss) { 'unexpected' }

      it 'raises JWT::InvalidIssuerError' do
        expect { decoder.verify_and_decode!(oidc_data) }.to raise_error(JWT::InvalidIssuerError)
      end
    end

    context 'with a JWT that has unexpected signer' do
      let(:signer) { 'unexpected' }

      it 'raises RedmineAmznAlbAuthn::InvalidSignerError' do
        expect { decoder.verify_and_decode!(oidc_data) }.to raise_error(RedmineAmznAlbAuthn::InvalidSignerError)
      end
    end

    context 'when the method is called twice with JWTs signed by the same key' do
      let(:oidc_data2) do
        JWT.encode({ sub: 2, exp: 2.minutes.from_now.to_i, iss: }, private_key, 'ES256', kid:, signer:)
      end

      it 'uses a cached key' do
        decoder.verify_and_decode!(oidc_data)
        decoder.verify_and_decode!(oidc_data2)

        expect(WebMock).to have_requested(:get, "https://example.com/#{kid}").once
      end
    end
  end
end
