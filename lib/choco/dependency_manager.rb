module Choco
  class DependencyManager
    
    @@to = 'lib/bundled.js'
    
    def self.to
      @@to
    end
    
    def self.add_dependency(filename)
      filename = remove_extension(filename)
      
      if filename.include?('controllers/')
        type = 'Controller'
      elsif filename.include?('helpers/')
        type = 'Helper'
      elsif filename.include?('models/')
        type = 'Model'
      elsif filename.include?('fixtures/')
        type = 'Fixture'        
      else
        type = 'Libs'
      end
      
      
      already_present = false
      File.new('Jimfile', "r").each do |line|
        if line.include?(filename)
          already_present = true
          break
        end
      end
      
      unless already_present
        jimfile = ""
        File.new('Jimfile', "r").each do |line|
          jimfile << line
          if line.include?("// #{type}")
            jimfile << "#{filename}\n"
          end
        end
        
        File.open('Jimfile', "wb") { |io| io.print jimfile }
        
        if type == 'Controller' || type == 'Helper'
          application_controller = ""
          file = extract_filename(filename)
          
          File.new('app/controllers/application_controller.js', "r").each do |line|
            application_controller << line
            if line.include?("/* Configure your #{type.downcase.pluralize} here")
              if type == 'Helper'
                application_controller << "\tthis.helpers(#{file});\n"
              else
                application_controller << "\t#{file}(this);\n"
              end
            end
          end
        
          File.open('app/controllers/application_controller.js', "wb") { |io| io.print application_controller }
        end
      end
    end
    
    def self.remove_dependency(filename)
      filename = remove_extension(filename)
      
      jimfile = ""
      File.new('Jimfile', "r").each do |line|
        jimfile << line unless line.include?(filename)
      end
      
      File.open('Jimfile', "wb") { |io| io.print jimfile }
      
      file = extract_filename(filename)
      application_controller = ""
      File.new('app/controllers/application_controller.js', "r").each do |line|
        application_controller << line unless line.include?(file)
      end
      
      File.open('app/controllers/application_controller.js', "wb") { |io| io.print application_controller }
    end
    
    private
    
    def self.remove_extension(filename)
      filename.gsub('.js', '')
    end
    
    def self.extract_filename(filename)
      filename.to_s.split('/').last.camelcase
    end
  end
end