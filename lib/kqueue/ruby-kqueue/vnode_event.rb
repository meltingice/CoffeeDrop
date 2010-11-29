module RubyKQueue
  class VNodeEvent < Event
    inline do |builder|
      builder.include "<sys/event.h>"
      builder.include "<sys/time.h>"
      builder.include "<errno.h>"
      
      builder.map_c_const({
        'EVFILT_VNODE'  => 'int',
          'NOTE_DELETE'   => 'int',
          'NOTE_WRITE'    => 'int',
          'NOTE_EXTEND'   => 'int',
          'NOTE_ATTRIB'   => 'int',
          'NOTE_LINK'     => 'int',
          'NOTE_RENAME'   => 'int',
          'NOTE_REVOKE'   => 'int'
      })
    end
    
    FILTER = EVFILT_VNODE
    
    # TODO: Use C_FLAGS to generate mapping above
    C_FLAGS = ['NOTE_WRITE', 'NOTE_EXTEND', 'NOTE_ATTRIB', 
               'NOTE_LINK', 'NOTE_RENAME', 'NOTE_REVOKE']
                   
    C_FLAGS.each do |flag|
      short_name = /NOTE_(\w+)$/.match(flag)[1]
      const_set(short_name, const_get(flag.to_sym))
    end
    
    @@ident_to_fd = {}
    
    def self.normalize_ident(ident)
      case ident
      when Fixnum
        ident
      when String
        full_path = File.expand_path(ident)
        if fd = @@ident_to_fd[full_path]
          fd.to_i
        else
          @@ident_to_fd[full_path] = File.open(full_path)
          @@ident_to_fd[full_path].to_i
        end
      end
    end
  end
end