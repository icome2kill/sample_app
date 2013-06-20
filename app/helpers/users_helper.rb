module UsersHelper
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email)
    gravatar_url = "https://secure.gravatar.com/avatars/#{gravatar_id}.png?s=#{options[:size]}" 
    return image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end