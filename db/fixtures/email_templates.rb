EmailTemplate.seed(:name) do |e|
  e.name = "welcome"
  e.subject = "Welcome to {{site.name}}"
  e.body = 
<<-END
{{user.display_name}}, your account {{site.name}} has been created.

  {{site.url}}/
END
end

EmailTemplate.seed(:name) do |e|
  e.name = 'invitation'
  e.subject = "You have been invited to {{site.name}}"
  e.body =
<<-END
You've been invited to try out a new website.

Visit this url below to signup for an account, and make sure you use this email address:

{{site.url}}/signup
END
end

EmailTemplate.seed(:name) do |e|
  e.name = 'referral'
  e.subject = "Your friend wants to share this website with you"
  e.body =
<<-END
Hello. Your friend wanted us to send this email to you to let you know about {{site.name}}. We gave them an option to include a personal note below.

Personal note
====================================

{{note}}

===

Please take a moment to visit {{site.name}}'s website {{site.url}}.

END
end

EmailTemplate.seed(:name) do |e|
  e.name = 'confirmation'
  e.subject = "You have sent the website to your friends"
  e.body =
<<-END
Hello. We sent the email to your friends about {{site.name}}.

We just wanted to take a moment to say: Thanks for sharing our website!
END
end

EmailTemplate.seed(:name) do |e|
  e.name = 'admin_confirmation'
  e.subject = "Someone sent a friend referral"
  e.body =
<<-END
{{referrer.email}} sent a referral about {{site.name}} to:

{% for referral in referrals %}
  {{referral.email}}
{% endfor %}
END
end
