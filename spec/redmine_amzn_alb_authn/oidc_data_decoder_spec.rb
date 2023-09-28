# frozen_string_literal: true

RSpec.describe RedmineAmznALBAuthn::OIDCDataDecoder do
  subject(:decoder) { described_class.new(oidc_data) }

  let(:oidc_data) { JWT.encode({ sub: 1, exp: 2.minutes.from_now.to_i }, private_key, 'ES256', typ: 'JWT', kid:) }
  let(:kid) { SecureRandom.uuid }
  let(:private_key) { OpenSSL::PKey::EC.generate('prime256v1') }

  describe '#verify_and_decode!' do
    before do
      stub_request(
        :get, "https://public-keys.auth.elb.ap-northeast-1.amazonaws.com/#{kid}",
      ).to_return(
        body: private_key.public_to_pem,
      )
    end

    it 'returns a payload and a header' do
      payload, header = decoder.verify_and_decode!

      expect(payload).to include 'exp', 'sub' => 1
      expect(header).to include 'kid', 'typ' => 'JWT', 'alg' => 'ES256'
    end

    context 'with a payload-modified JWT' do
      let(:oidc_data) do
        jwt = JWT.encode({ sub: 1, exp: 2.minutes.from_now.to_i }, private_key, 'ES256', typ: 'JWT', kid:)
        header, _payload, signature = jwt.split('.')
        modified_payload = JWT::Base64.url_encode({ sub: 'modified' }.to_json)
        "#{header}.#{modified_payload}.#{signature}"
      end

      it 'raises JWT::VerificationError' do
        expect { decoder.verify_and_decode! }.to raise_error(JWT::VerificationError)
      end
    end

    context 'when the method is called twice with JWTs signed by the same key' do
      let(:oidc_data2) { JWT.encode({ sub: 2, exp: 2.minutes.from_now.to_i }, private_key, 'ES256', typ: 'JWT', kid:) }

      it 'uses a cached key' do
        decoder.verify_and_decode!

        decoder2 = described_class.new(oidc_data2)
        decoder2.verify_and_decode!

        expect(WebMock).to have_requested(
          :get, "https://public-keys.auth.elb.ap-northeast-1.amazonaws.com/#{kid}",
        ).once
      end
    end
  end
end
