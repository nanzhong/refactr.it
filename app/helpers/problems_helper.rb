module ProblemsHelper

  def language_selector(selected = :text)
    lang_select = Problem::LANGUAGES.map do |lang|
      case lang
      when :c_cpp
        [ 'c/c++', lang ]
      when :csharp
        [ 'c#', lang ]
      when :golang
        [ 'go', lang ]
      when :objectivec
        [ 'obj-c', lang ]
      when :text
        [ 'plaintext', lang ]
      else
        [ lang.to_s, lang ]
      end
    end
  end

end
