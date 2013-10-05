module Pippi::Checks
  class SelectFollowedByFirst < Check

    def initialize(ctx)
      super
      @result_of_select_invocation = nil
    end

    def c_call_event(tp)
      # was this the object we called select on?
      # TODO if any methods were invoked in the meantime, don't check this
      if tp.defined_class == Array && tp.method_id == :first && @result_of_select_invocation.object_id == tp.self.object_id
        ctx.report.add(Pippi::Problem.new(:line_number => tp.lineno, :file_path => tp.path, :check_class => self.class))
      end
    end

    def c_return_event(tp)
      # grab the result of the select call
      if tp.defined_class == Array && tp.method_id == :select
        @result_of_select_invocation = tp.return_value
      end
    end

    class Documentation

      def description
        "Don't use #select followed by #first; instead use #detect"
      end

      def sample
        "[1,2,3].select {|x| x > 1 }.first"
      end

      def instead_use
        "[1,2,3].detect {|x| x > 1 }"
      end

    end

  end
end
