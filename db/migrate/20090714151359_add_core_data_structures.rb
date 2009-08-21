class AddCoreDataStructures < ActiveRecord::Migration
  def self.up
    create_table :site_settings do |t|
      t.string :url
      t.string :description
      t.string :name
      t.string :admin_email
      t.boolean :beta_invites, :default => false
      t.boolean :user_avatars, :default => false
      t.boolean :referrals,    :default => false
      
      t.timestamps
    end
    
    create_table :profiles do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.integer :referral_id
      t.integer :user_id
      t.boolean :subscribed, :default => false
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size

      t.timestamps
    end
    add_index :profiles, :email
    add_index :profiles, :user_id
    
    create_table :invites do |t|
      t.string :email
      t.integer :user_id
      t.integer :inviter_id
      t.boolean :used, :default => false
      t.boolean :approved, :default => false
      t.datetime :sent_at

      t.timestamps
    end
    add_index :invites, :email
    
    create_table :email_templates do |t|
      t.string   :name
      t.string   :subject
      t.text     :body

      t.timestamps
    end
    
    create_table :delayed_jobs, :force => true do |table|
      table.integer  :priority, :default => 0      # Allows some jobs to jump to the front of the queue
      table.integer  :attempts, :default => 0      # Provides for retries, but still fail eventually.
      table.text     :handler                      # YAML-encoded string of the object that will do work
      table.string   :last_error                   # reason for last failure (See Note below)
      table.datetime :run_at                       # When to run. Could be Time.now for immediately, or sometime in the future.
      table.datetime :locked_at                    # Set when a client is working on this object
      table.datetime :failed_at                    # Set when all retries have failed (actually, by default, the record is deleted instead)
      table.string   :locked_by                    # Who is working on this object (if locked)
      table.timestamps
    end

  end

  def self.down
    drop_table :site_settings
    drop_table :profiles
    drop_table :invites
    drop_table :email_templates
    drop_table :delayed_jobs
  end
end
