Pod::Spec.new do |s|
  s.name 				= 'SocialEngine'
  s.version 			= '1.2'
  s.summary 			= 'Simplify the sharing of a message, link or an image.'
  s.license 			= { :type => 'Shareware', :file => 'LICENSE' }
  s.authors 			= { 'Danilo Priore' => 'support@prioregroup.com' }
  s.homepage 			= 'https://github.com/priore/SocialEngine'
  s.social_media_url 	= 'https://twitter.com/danilopriore'
  s.source 				= { git: 'https://github.com/priore/SocialEngine.git', :tag => "v#{s.version}" }
  s.frameworks			= 'Social', 'Twitter', 'MessageUI', 'Accounts'
  s.requires_arc 			= true
  s.source_files			= 'SocialNativeEngine/ClassEngine/*.{h,m}'
  s.resource				= 'SocialNativeEngine/ClassEngine/*.html'
  s.ios.platform			= '6.0'
  s.ios.deployment_target	= '6.0'
end
