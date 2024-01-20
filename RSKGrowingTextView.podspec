Pod::Spec.new do |s|
  s.name          = 'RSKGrowingTextView'
  s.version       = '8.0.0'
  s.summary       = 'A light-weight UITextView subclass that automatically grows and shrinks.'
  s.description   = <<-DESC
                   A light-weight UITextView subclass that automatically grows and shrinks based on the size of user input and can be constrained by maximum and minimum number of lines.
                   DESC
  s.homepage      = 'https://github.com/ruslanskorb/RSKGrowingTextView'
  s.license       = { :type => 'Apache', :file => 'LICENSE' }
  s.authors       = { 'Ruslan Skorb' => 'ruslan.skorb@gmail.com' }
  s.source        = { :git => 'https://github.com/ruslanskorb/RSKGrowingTextView.git', :tag => s.version.to_s }
  s.platform      = :ios, '12.0'
  s.swift_version = '5.7'
  s.source_files  = 'RSKGrowingTextView/*.{h,swift}'
  s.requires_arc  = true
  s.dependency 'RSKPlaceholderTextView', '8.0.0'
end
