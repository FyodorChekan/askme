namespace :deploy do
  namespace :check do
    before :linked_files, :set_master_key do
      on roles(:app), in: :sequence, wait: 10 do
        unless test("[ -f #{shared_path}/config/master.key ]")
          upload! 'config/master.key', "#{shared_path}/config/master.key"
        end
      end
    end
  end
  namespace :passenger do
    desc 'Restart your Passenger application'
    task :restart do
      restart_with_touch = fetch(:passenger_restart_with_touch, nil)
      if restart_with_touch.nil? && fetch(:sshkit_backend) == SSHKit::Backend::Printer
        run_locally do
          fatal "In a dry run, we cannot check the passenger version, and therefore can't guess which passenger restart method to use.  Therefore, using --dry-run without setting `passenger_restart_with_touch` to either `true` or `false` is not supported."
        end
        exit
      end
      on roles(fetch(:passenger_roles)), in: fetch(:passenger_restart_runner), wait: fetch(:passenger_restart_wait), limit: fetch(:passenger_restart_limit) do
        with fetch(:passenger_environment_variables) do
          within(fetch(:passenger_in_gemfile, false) ? release_path : capture(:pwd)) do
            if restart_with_touch.nil?
              # 'passenger -v' may output one of the following depending on the version:
              # Phusion Passenger version x.x.x
              # Phusion Passenger Enterprise version x.x.x
              # Phusion Passenger x.x.x
              # Phusion Passenger Enterprise x.x.x
              # and it may have a (R) after Passenger
              passenger_version = capture(:passenger, '-v').match(/^Phusion Passenger(\(R\))? (Enterprise )?(version )?(.*)$/)[4]
            end
end