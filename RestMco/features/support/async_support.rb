require 'timeout'

module AsyncSupport
    def eventually
        Timeout::timeout(10) do 
          loop do
              begin
                  yield
              rescue Exception => error
              end
              return if error.nil?
              sleep 0.5
          end
        end
    end
end
World(AsyncSupport)

