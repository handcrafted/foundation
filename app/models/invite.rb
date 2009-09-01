class Invite < ActiveRecord::Base
  
  belongs_to :inviter, :class_name => "User", :foreign_key => "inviter_id"
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  
  validates_presence_of :email, :on => :create, :message => "can't be blank"
  validates_uniqueness_of :email, :on => :create, :message => "has already been invited"
  validate :ensure_new_user
  validate :ensure_inviter_has_invites, :if => Proc.new {|invite| !invite.inviter_id.nil?}
  
  before_create :remove_inviter_invite
  before_save :auto_approve
  
  attr_accessible :email, :inviter_id
  
  named_scope :usable, lambda {|email| {:conditions => ["email = ? AND used = ? AND approved = ?", email, false, true]} }
  named_scope :unused, :conditions => ["used = ?", false]
  named_scope :used, :conditions => ["used = ?", true]
  named_scope :unapproved, :conditions => ["approved = ? OR approved IS NULL", false]
  
  def ensure_new_user
    errors.add(:email, "has already been used for an active account") unless new_user?
  end
  
  def ensure_inviter_has_invites
    errors.add(:inviter, "is out of invites") unless inviter && inviter.has_invites?
  end
  
  def new_user?
    User.find_by_email(email).nil?
  end
  
  def use!
    self.update_attribute(:used, true)
  end
  
  def add_inviter(user)
    self.inviter = user
  end
  
  def approve
    self.update_attribute(:approved, true)
  end
  
  def auto_approve
    approve unless self.inviter.nil? || approved?
  end
  
  def unapproved?
    !approved?
  end
  
  def remove_inviter_invite
    unless inviter.nil?
      inviter.invites -= 1
      inviter.save
    end
  end
  
  def send!
    if approved? && unsent?
      InviteMailer.send_later(:deliver_invite_notification, self)
      self.update_attribute(:sent_at, Time.now)
    end
  end
  
  def unsent?
    sent_at.nil? || sent_at < Time.now
  end
  
  def sent?
    !(sent_at.nil? || sent_at > Time.now)
  end
  
end
