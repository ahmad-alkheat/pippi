module Pippi::Checks

  class MapFollowedByFlatten < Check

    def decorate
      Array.class_exec(self) do |my_check|
        # How to do this without a super-intrusive class variable?
        @@_pippi_check = my_check
        def map(&blk)
          result = super
          def result.flatten
            result = super
            problem_location = caller_locations.detect {|c| c.to_s !~ /byebug|lib\/pippi\/checks/ }
            @@_pippi_check.add_problem(problem_location.lineno, problem_location.path)
            result
          end
          result
        end
      end
    end

    def add_problem(line_number, file_path)
      ctx.report.add(Pippi::Problem.new(:line_number => line_number, :file_path => file_path, :check_class => self.class))
    end

    class Documentation
      def description
        "Don't use map followed by flatten; use flat_map instead"
      end
      def sample
        "[1,2,3].map {|x| [x,x+1] }.flatten"
      end
      def instead_use
        "[1,2,3].flat_map {|x| [x, x+1]}"
      end
    end

  end

end
