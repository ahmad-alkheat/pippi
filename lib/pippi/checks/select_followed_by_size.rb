module Pippi::Checks

  class SelectFollowedBySize < Check

    module MySize
      def size
        result = super()
        problem_location = caller_locations.detect {|c| c.to_s !~ /byebug|lib\/pippi\/checks/ }
        self.class._pippi_check_select_followed_by_size.add_problem(problem_location.lineno, problem_location.path)
        self.class._pippi_check_select_followed_by_size.method_names_that_indicate_this_is_being_used_as_a_collection.each do |this_means_its_ok_sym|
          define_singleton_method(this_means_its_ok_sym, self.class._pippi_check_select_followed_by_size.clear_fault_proc(problem_location.lineno, problem_location.path))
        end
        result
      end
    end

    module MySelect
      def select(&blk)
        result = super
        if self.class._pippi_check_select_followed_by_size.nil?
          # Ignore Array subclasses since select or size may have difference meanings
        else
          result.extend MySize
          self.class._pippi_check_select_followed_by_size.array_mutator_methods.each do |this_means_its_ok_sym|
            result.define_singleton_method(this_means_its_ok_sym, self.class._pippi_check_select_followed_by_size.its_ok_watcher_proc)
          end
        end
        result
      end
    end

    def method_names_that_indicate_this_is_being_used_as_a_collection
      [:collect!, :compact!, :flatten!, :map!, :reject!, :reverse!, :rotate!, :select!, :shuffle!, :slice!, :sort!, :sort_by!, :uniq!, :collect, :compact, :flatten, :map, :reject, :reverse, :rotate, :select, :shuffle, :slice, :sort, :sort_by, :uniq]
    end

    def clear_fault_proc(lineno, path)
      Proc.new do
        self.class._pippi_check_select_followed_by_size.clear_fault(lineno, path)
      end
    end

    def clear_fault(lineno, path)
      ctx.report.remove(lineno, path, self.class)
    end

    def its_ok_watcher_proc
      Proc.new do
        singleton_class.ancestors.detect {|x| x == MySize }.instance_eval { remove_method :size }
        super()
      end
    end

    def decorate
      Array.class_exec(self) do |my_check|
        @_pippi_check_select_followed_by_size = my_check
        def self._pippi_check_select_followed_by_size
          @_pippi_check_select_followed_by_size
        end
      end
      Array.prepend MySelect
    end

    class Documentation
      def description
        "Don't use select followed by size; use count instead"
      end
      def sample
        "[1,2,3].select {|x| x > 1 }.size"
      end
      def instead_use
        "[1,2,3].count {|x| x > 1 }"
      end
    end

  end

end
