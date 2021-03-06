require 'spec_helper'

describe AvatarHelper, type: :helper, with_settings: { protocol: 'http' }  do
  let(:user) { FactoryGirl.build_stubbed(:user) }
  let(:avatar_stub) { FactoryGirl.build_stubbed(:avatar_attachment) }

  before do
    allow(user).to receive(:local_avatar_attachment).and_return avatar_stub
  end

  def expected_image_tag(user)
    tag_options = { title: user.name,
                    alt: 'Avatar',
                    class: 'avatar' }

    image_tag expected_url(user), tag_options
  end

  def expected_url(user)
    users_dump_avatar_url(user)
  end

  def expected_gravatar_url(user)
    digest = Digest::MD5.hexdigest(user.mail)
    host = "http://gravatar.com"

    "#{host}/avatar/#{digest}?secure=false"
  end

  def expected_gravatar_image_tag(user)
    tag_options = { title: user.name,
                    alt: 'Gravatar',
                    class: 'avatar' }

    image_tag expected_gravatar_url(user), tag_options
  end

  describe '#avatar' do
    context 'when enabled', with_settings: { gravatar_enabled?: true } do
      it "should return the image attached to the user" do
        expect(helper.avatar(user)).to be_html_eql(expected_image_tag(user))
      end

      it "should return the gravatar image if no image uploaded for the user" do
        allow(user).to receive(:local_avatar_attachment).and_return nil

        expect(helper.avatar(user)).to be_html_eql(expected_gravatar_image_tag(user))
      end
    end

    context 'when disabled', with_settings: { gravatar_enabled?: false } do
      it "should return blank if image attached to the user but gravatars disabled" do
        expect(helper.avatar(user)).to be_html_eql(expected_image_tag(user))
      end
    end
  end

  describe '#avatar_url' do
    context 'when enabled', with_settings: { gravatar_enabled?: true } do
      it "should return the url to the image attached to the user" do
        expect(helper.avatar_url(user)).to eq(expected_url(user))
      end

      it "should return the gravatar url if no image uploaded for the user" do
        allow(user).to receive(:local_avatar_attachment).and_return nil

        expect(helper.avatar_url(user)).to eq(expected_gravatar_url(user))
      end
    end

    context 'when disabled', with_settings: { gravatar_enabled?: false } do
      it "should return the url if image attached to the user but gravatars disabled" do
        expect(helper.avatar_url(user)).to eq(expected_url(user))
      end
    end
  end
end
