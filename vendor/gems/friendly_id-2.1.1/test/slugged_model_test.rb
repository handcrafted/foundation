# encoding: utf-8

require File.dirname(__FILE__) + '/test_helper'

class SluggedModelTest < Test::Unit::TestCase

  context "A slugged model with default FriendlyId options" do

    setup do
      Post.friendly_id_options = FriendlyId::DEFAULT_FRIENDLY_ID_OPTIONS.merge(:column => :title, :use_slug => true)
      Post.delete_all
      Person.delete_all
      Slug.delete_all
      @post = Post.new :title => "Test post", :content => "Test content"
      @post.save!
    end

    should "have friendly_id options" do
      assert_not_nil Post.friendly_id_options
    end

    should "have a slug" do
      assert_not_nil @post.slug
    end

    should "be findable by its friendly_id" do
      assert Post.find(@post.friendly_id)
    end

    should "be findable by its regular id" do
      assert Post.find(@post.id)
    end

    should "generate slug text" do
      post = Post.new :title => "Test post", :content => "Test content"
      assert_not_nil @post.slug_text
    end

    should "respect finder conditions" do
      assert_raises ActiveRecord::RecordNotFound do
        Post.find(@post.friendly_id, :conditions => "1 = 2")
      end
    end

    should "raise an error if the friendly_id text is reserved" do
      assert_raises(FriendlyId::SlugGenerationError) do
        Post.create!(:title => "new")
      end
    end

    should "raise an error if the friendly_id text is blank" do
      assert_raises(FriendlyId::SlugGenerationError) do
        Post.create(:title => "")
      end
    end

    should "raise an error if the normalized friendly id becomes blank" do
      assert_raises(FriendlyId::SlugGenerationError) do
        post = Post.create!(:title => "-.-")
      end
    end

    should "not make a new slug unless the friendly_id method value has changed" do
      @post.content = "Changed content"
      @post.save!
      assert_equal 1, @post.slugs.size
    end

    should "make a new slug if the friendly_id method value has changed" do
      @post.title = "Changed title"
      @post.save!
      assert_equal 2, @post.slugs.size
    end

    should "have a slug sequence of 1 by default" do
      assert_equal 1, @post.slug.sequence
    end

    should "increment sequence for duplicate slug names" do
      @post2 = Post.create! :title => @post.title, :content => "Test content for post2"
      assert_equal 2, @post2.slug.sequence
    end

    should "have a friendly_id that terminates with -- and the slug sequence if the sequence is greater than 1" do
      @post2 = Post.create! :title => @post.title, :content => "Test content for post2"
      assert_match(/--2\z/, @post2.friendly_id)
    end

    should "not strip diacritics" do
      @post = Post.new(:title => "¡Feliz año!")
      assert_match(/#{'ñ'}/, @post.slug_text)
    end

    should "not convert to ASCII" do
      @post = Post.new(:title => "katakana: ゲコゴサザシジ")
      assert_equal "katakana-ゲコゴサザシジ", @post.slug_text
    end

    should "allow the same friendly_id across models" do
      @person = Person.create!(:name => @post.title)
      assert_equal @person.friendly_id, @post.friendly_id
    end

    should "truncate slug text longer than the max length" do
      @post = Post.new(:title => "a" * (Post.friendly_id_options[:max_length] + 1))
      assert_equal @post.slug_text.length, Post.friendly_id_options[:max_length]
    end

    should "be able to reuse an old friendly_id without incrementing the sequence" do
      old_title = @post.title
      old_friendly_id = @post.friendly_id
      @post.title = "A changed title"
      @post.save!
      @post.title = old_title
      @post.save!
      assert_equal old_friendly_id, @post.friendly_id
    end

    should "allow eager loading of slugs" do
      assert_nothing_raised do
        Post.find(@post.friendly_id, :include => :slugs)
      end
    end

    context "and configured to strip diacritics" do
      setup do
        Post.friendly_id_options = Post.friendly_id_options.merge(:strip_diacritics => true)
      end

      should "strip diacritics from Roman alphabet based characters" do
        @post = Post.new(:title => "¡Feliz año!")
        assert_no_match(/#{'ñ'}/, @post.slug_text)
      end
    end

    context "and configured to convert to ASCII" do
      setup do
        Post.friendly_id_options = Post.friendly_id_options.merge(:strip_non_ascii => true)
      end

      should "strip non-ascii characters" do
        @post = Post.new(:title => "katakana: ゲコゴサザシジ")
        assert_equal "katakana", @post.slug_text
      end
    end

    context "that doesn't have a slug" do

      setup do
        @post.slug.destroy
        @post = Post.find(@post.id)
      end

      should "have a to_param method that returns the id cast to a string" do
        assert_equal @post.id.to_s, @post.to_param
      end

    end

    context "when found using its friendly_id" do
      setup do
        @post = Post.find(@post.friendly_id)
      end

      should "indicate that it was found using the friendly_id" do
        assert @post.found_using_friendly_id?
      end

      should "not indicate that it has a better id" do
        assert !@post.has_better_id?
      end

      should "not indicate that it was found using its numeric id" do
        assert !@post.found_using_numeric_id?
      end

      should "have a finder slug" do
        assert_not_nil @post.finder_slug
      end

    end

    context "when found using its regular id" do
      setup do
        @post = Post.find(@post.id)
      end

      should "indicate that it was not found using the friendly id" do
        assert !@post.found_using_friendly_id?
      end

      should "indicate that it has a better id" do
        assert @post.has_better_id?
      end

      should "indicate that it was found using its numeric id" do
        assert @post.found_using_numeric_id?
      end

      should "not have a finder slug" do
        assert_nil @post.finder_slug
      end

    end

    context "when found using an outdated friendly id" do
      setup do
        old_id = @post.friendly_id
        @post.title = "Title changed"
        @post.save!
        @post = Post.find(old_id)
      end

      should "indicate that it was found using a friendly_id" do
        assert @post.found_using_friendly_id?
      end

      should "indicate that it has a better id" do
        assert @post.has_better_id?
      end

      should "not indicate that it was found using its numeric id" do
        assert !@post.found_using_numeric_id?
      end

      should "should have a finder slug different from its default slug" do
        assert_not_equal @post.slug, @post.finder_slug
      end

    end

    context "when using an array as the find argument" do

      setup do
        @post2 = Post.create!(:title => "another post", :content => "more content")
      end

      should "return results when passed an array of non-friendly ids" do
        assert_equal 2, Post.find([@post.id, @post2.id]).size
      end

      should "return results when passed an array of friendly ids" do
        assert_equal 2, Post.find([@post.friendly_id, @post2.friendly_id]).size
      end

      should "return results when passed a mixed array of friendly and non-friendly ids" do
        assert_equal 2, Post.find([@post.friendly_id, @post2.id]).size
      end

      should "return results when passed an array of non-friendly ids, of which one represents a record with multiple slugs" do
        @post2.update_attributes(:title => 'another post [updated]')
        assert_equal 2, Post.find([@post.id, @post2.id]).size
      end

      should "indicate that the results were found using a friendly_id" do
        @posts = Post.find [@post.friendly_id, @post2.friendly_id]
        @posts.each { |p| assert p.found_using_friendly_id? }
      end

      should "raise an error when all records are not found" do
        assert_raises(ActiveRecord::RecordNotFound) do
          Post.find([@post.friendly_id, 'non-existant-slug-record'])
        end
      end

      should "allow eager loading of slugs" do
        assert_nothing_raised do
          Post.find([@post.friendly_id, @post2.friendly_id], :include => :slugs)
        end
      end

    end

  end

end