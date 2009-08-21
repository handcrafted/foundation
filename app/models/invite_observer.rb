class InviteObserver < ActiveRecord::Observer
  
  def after_save(invite)
    invite.send! unless invite.sent? || invite.unapproved?
  end
  
end