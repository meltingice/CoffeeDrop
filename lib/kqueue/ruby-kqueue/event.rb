module RubyKQueue
  class Event
    inline do |builder|
      builder.include "<sys/event.h>"
      builder.include "<sys/time.h>"
      builder.include "<errno.h>"
      
      builder.prefix <<-"END"
        static int kq;
        static VALUE cRubyKQueue;
        static VALUE cKqueueEvent;
        static VALUE m_trigger;
        
        #define MAX_EVENTS 10
      END
      
      builder.map_c_const({
        'EV_ADD'      => 'int',
        'EV_ENABLE'   => 'int',
        'EV_DISABLE'  => 'int',
        'EV_DELETE'   => 'int',
        'EV_ONESHOT'  => 'int',
        'EV_CLEAR'    => 'int',
        'EV_EOF'      => 'int',
      })
      
      builder.add_to_init <<-"END"
        kq = kqueue();
        cRubyKQueue = rb_const_get(rb_cObject, rb_intern("RubyKQueue"));
        cKqueueEvent = rb_const_get(cRubyKQueue, rb_intern("Event"));
        
        m_trigger = rb_intern("trigger");
        
        if (kq == -1) {
          rb_raise(rb_eStandardError, "kqueue initilization failed");
        }
      END
      
      builder.c_singleton <<-"END"
        VALUE c_register(VALUE ident, VALUE flags, VALUE filter, VALUE fflags) {
          struct kevent new_event;
          
          EV_SET(&new_event, FIX2INT(ident), FIX2INT(filter),
                 FIX2INT(flags), FIX2INT(fflags), 0, 0);
          
          if (-1 == kevent(kq, &new_event, 1, NULL, 0, NULL)) {
            rb_raise(rb_eStandardError, strerror(errno));
          }
          
          return Qnil;
        }
      END
      
      builder.c_singleton <<-"END"
        VALUE c_handle_events() {
          int nevents, i, num_to_fetch;
          struct kevent *events;
          struct timespec timeout;
          fd_set read_set;
      
          FD_ZERO(&read_set);
          FD_SET(kq, &read_set);
          
          events = (struct kevent*)malloc(MAX_EVENTS * sizeof(struct kevent));
          bzero(&timeout, sizeof(struct timespec));
          
          if (NULL == events) {
            rb_raise(rb_eStandardError, strerror(errno));
          }
      
          // Don't actually run this method until we've got an event
          if (rb_thread_select(kq + 1, &read_set, NULL, NULL, NULL) <= 0) {
            free(events);
            rb_raise(rb_eStandardError, strerror(errno));
          }
      
          // In testing kevent has been blocking, even though select continues
          // so set a tiny timeout just in case. It _should_ execute immediately
          timeout.tv_nsec = 10;
          nevents = kevent(kq, NULL, 0, events, MAX_EVENTS, &timeout);
          
          if (-1 == nevents) {
            free(events);
            rb_raise(rb_eStandardError, strerror(errno));
          } else {
            for (i = 0; i < nevents; i++) {
              rb_funcall(cKqueueEvent, m_trigger, 3, INT2NUM(events[i].ident), INT2NUM(events[i].filter), INT2NUM(events[i].fflags));
            }
          }
      
          free(events);
          
          return INT2FIX(nevents);
        }
      END
    end
    
    @@registry = {}
    
    # TODO: Allow a lower level interface for direct manipulation
    #       of registration flags (EV_ONESHOT and the like)
    def self.register(ident, filter_or_filter_class, *flags, &block)
      if filter_or_filter_class.is_a? Class
        ident = filter_or_filter_class.normalize_ident(ident)
        filter = filter_or_filter_class::FILTER
      else
        filter = filter_or_filter_class
      end
      
      @@registry[filter] ||= {}
      @@registry[filter][ident] ||= {}
        
      flags.each do |flag|
        @@registry[filter][ident][flag] = block
      end
      
      mask = flags.inject {|msk, flg| msk | flg }
      
      c_register(ident, EV_ADD | EV_ENABLE, filter, mask)
    end
    
    def self.deregister(ident, filter_or_filter_class, *flags)
      # puts "Calling deregister"
      # puts "Registry like: #{@@registry.inspect}"
      if filter_or_filter_class.is_a? Class
        ident = filter_or_filter_class.normalize_ident(ident)
        filter = filter_or_filter_class::FILTER
      else
        filter = filter_or_filter_class
      end
      
      flags.each do |flag|
        @@registry[filter][ident].delete(flag) rescue nil
      end
      
      # puts "Now registry like: #{@@registry.inspect}"
      
      mask = flags.inject {|msk, flg| msk | flg }
      
      # puts "Calling c_register"
      c_register(ident, EV_DELETE, filter, mask)
    end
    
    def self.trigger(id, filter, flag)
      Event.new(id, filter, flag).trigger
    end
    
    def self.handle
      @@handler_thread ||= Thread.new { loop { c_handle_events } }
    end
    
    def self.registry
      @@registry
    end
    
    def self.respond_to?(item, *args)
      case item
      when Event
        self.registry[item.filter][item.id][item.flag].respond_to?(:call) rescue false
      else
        super
      end
    end
    
    # Override to transform a 'nice' identifier to a cannonical kqueue friendly form
    # eg. VNodes are referenced by paths in ruby, but need a file descriptor in C
    def self.normalize_ident(ident)
      ident
    end
    
    attr_reader :id, :filter, :flag
    
    def initialize(id, filter_or_filter_class, flag)      
      if filter_or_filter_class.is_a? Class
        # Coercion to canonical id and filter (for ruby niceness)
        @id = filter_or_filter_class.normalize_ident(id)
        @filter = filter_or_filter_class::FILTER
      else
        # Assume cannonical id and filter (as int) (for c calling)
        @id = id
        @filter = filter_or_filter_class
      end
      
      @flag = flag
    end
    
    def trigger
      if self.class.respond_to? self
        self.class.registry[filter][id][flag].call(self)
      else
        $stderr.puts "Trigger got an event it didn't respond to. Bug?"
        # TODO: ignore or raise?
      end
    end
    
    def register
      self.class.register(self.id, self.filter, self.flag)
    end
    
    def deregister
      self.class.deregister(self.id, self.filter, self.flag)
    end
    
  end
end