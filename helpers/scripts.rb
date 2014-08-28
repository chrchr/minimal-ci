require_relative 'payload'
require_relative 'output'

def verify_scripts(scripts)
  missing_scripts = scripts.reject { |script| File.exists? File.expand_path(File.dirname(script)) }
  unless missing_scripts.empty?
    throw_error "Stopping. Couldn't find scripts to run:\n#{missing_scripts}"
  end
end

def from_workspace(job)
  path = workspace_path_for job
  puts_info "Working from '#{path}' for '#{job}'"
  FileUtils.mkdir_p path
  Dir.chdir path do
    yield
  end
end

def workspace_path_for(job_name)
  "workspaces/#{job_name}"
end

def run_script(path, logger=nil)
  logger.info "Running '#{path}'..." if logger
  IO.popen(path) do |io|
    while line = io.gets
      logger.info line if logger
    end
  end
  logger.info "Script done. (exit status: #{$?.exitstatus})" if logger
end

def run_scripts(job_name, scripts, logger=nil)
  scripts.map! { |path| File.expand_path path }
  from_workspace(job_name) do
    scripts.each { |path| run_script path, logger }
  end
end
