require 'spec_helper'

RSpec.describe Kamikakushi::Kaonashi do
  let!(:post) { Post.create(content: 'demo') }
  let!(:comment) { post.comments.create(post_id: post.id, content: 'comment xxxx') }
  after { Post.with_deleted.delete_all }
  after { Comment.with_deleted.delete_all }

  describe 'select record' do
    subject { Comment.all.to_sql }
    it { is_expected.to include 'WHERE "posts"."deleted_at" IS NULL' }
  end

  describe '#destroyed?' do
    it do
      expect {
        post.destroy
      }.to change(comment, :destroyed?).from(false).to(true)
    end
  end

  describe 'scope' do
    let!(:deleted_post) { Post.create(content: 'deleted') }
    let!(:deleted_comment) { deleted_post.comments.create(post_id: deleted_post.id, content: 'deleted') }

    before do
      deleted_post.destroy
    end

    describe '.with_deleted' do
      subject { Comment.with_deleted.all.to_a }
      it { is_expected.to include comment }
      it { is_expected.to include deleted_comment }
    end

    describe '.without_deleted' do
      subject { Comment.without_deleted.all.to_a }
      it { is_expected.to include comment }
      it { is_expected.not_to include deleted_comment }
    end

    describe '.only_deleted' do
      subject { Comment.only_deleted.all.to_a }
      it { is_expected.not_to include comment }
      it { is_expected.to include deleted_comment }
    end
  end
end
