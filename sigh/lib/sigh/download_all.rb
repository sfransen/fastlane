
module Sigh
	class DownloadAll
		# Download all valid provisioning profiles

		def download_all
			UI.message "Starting login with user '#{Sigh.config[:username]}'"
			Spaceship.login(Sigh.config[:username], nil)
			Spaceship.select_team
			UI.message "Successfully logged in"
			FileUtils.mkdir_p(Sigh.config[:output_path])

			UI.message "#####################"
			UI.message "#####################"
			UI.message "#####################"
			UI.message "#####################"
			UI.message "Gather All the Provison Profiles data Now"
			t3 = Time.now

			File.delete('ProfileDetail.txt') if File.exist?('ProfileDetail.txt')

			Spaceship.provisioning_profile.all.each do |profile2|
			t4 = Time.now
			deltaTotal = t4 - t3
			minutesnow = deltaTotal / 60
			UI.message "finished in #{minutesnow} minutes Gather the info"
				if profile2.valid?
					UI.message "================================"
 					UI.message "-------------------------"
 					p profile2
 					UI.message "-------------------------"
					values = profile2.app.features
# 					p values
 					hh = File.open('ProfileDetail.txt', 'a')
 					hh.write("#{profile2.devices.map(&:id).length}\t#{profile2.name}\t#{profile2.app.prefix}\t#{profile2.app.prefix}.#{profile2.app.bundle_id}\t#{profile2.type}\t#{profile2.distribution_method}\t")
 					#hh.write("\t")
					hh.write("#{profile2.app.enabled_features}\t")
					hh.write("#{profile2.app.dev_push_enabled}\t#{profile2.app.prod_push_enabled}\t#{profile2.app.app_groups_count}\t#{profile2.app.cloud_containers_count}\t#{profile2.app.identifiers_count}\t#{profile2.app.is_wildcard}")
					#hh.write( values )
 					hh.write("\n")
# 					hh.write('ProfileDetail.txt', "#{profile2.app.features}\n", hh.size('ProfileDetail.txt'), mode: 'a')
 					hh.close
# 					p "#{profile2.devices.map(&:id).length} #{profile2.name}"
					UI.message "Add All Devices to Each Provison Profiles Now"
					UI.message "Update profile '#{profile2.name}'"
					update_profile(profile2)
					UI.message "================================"
				else
					UI.important "Skipping invalid/expired profile '#{profile2.name}'"
				end
			end
			t5 = Time.now
			deltaTotal2 = t5 - t3
			minutesnow2 = deltaTotal2 / 60
			UI.message "finished in #{minutesnow2} minutes to add all Devices to each Provison Profile"
			UI.message "#####################"
			UI.message "#####################"
			UI.message "#####################"
			UI.message "#####################"
			UI.message "Download Each Provison Profiles Now"
			UI.message "#####################"
			UI.message "#####################"
			UI.message "#####################"
			UI.message "#####################"

			t6 = Time.now
			UI.message "Gather All the Provison Profiles data the Second Time Now"
			Spaceship.provisioning_profile.all.each do |profile|
			t7 = Time.now
			deltaTotal3 = t7 - t6
			minutesnow3 = deltaTotal3 / 60
			UI.message "finished in #{minutesnow3} minutes to Gather the info again"
				if profile.valid?
					UI.message "Downloading profile '#{profile.name}'..."
					download_profile(profile)
				else
					UI.important "Skipping invalid/expired profile '#{profile.name}'"
				end
			end
			t8 = Time.now
			deltaTotal6 = t8 - t3
			minutesnow6 = deltaTotal6 / 60
			print "============================ finished in #{minutesnow6} minutes \n"
		end

		def update_profile(profile)
			FileUtils.mkdir_p(Sigh.config[:output_path])
			#profile_name = "#{profile.class.pretty_type}_#{profile.app.bundle_id}.mobileprovision" # default name
			profile_name = "#{profile.name}.mobileprovision"

			# Push the changes back to the Apple Developer Portal
			UI.message "profile Name is " + profile_name

			UI.message "#####################"

			UI.message "profile.name is " + profile.name
			UI.message "type is " + profile.type
			UI.message "distribution_method is " + profile.distribution_method
			UI.message "profile.id is " + profile.id
			UI.message "#####################"

			if profile.type.include? "tvOS"
				UI.message "#####################"
				UI.message "This is iTV Profiles "
				UI.message "#####################"
				p	profile
				goodname = profile_name.gsub(" ", "_")
				UI.message "Don't add Devices to this Provision Profile " + goodname
			else
				if profile.distribution_method.include? "store"
					p	profile
					goodname = profile_name.gsub(" ", "_")
					UI.message "Don't add Devices to this Provision Profile " + goodname
				elsif profile.distribution_method.include? "inhouse"
					p	profile
					goodname = profile_name.gsub(" ", "_")
					UI.message "Don't add Devices to this Provision Profile " + goodname
				else
					UI.message profile
					UI.important "Updating Devices in this profile to include all devices"
					profile.devices = Spaceship.device.all_for_profile_type(profile.type)

					UI.message "Saved Back to Apple"
					profile.update!
				 end
			 end
		end

		def download_profile(profile)
			FileUtils.mkdir_p(Sigh.config[:output_path])
			profile_name = "#{profile.name}.mobileprovision"
			goodname2 = profile_name.gsub(" ", "_")
			goodname3 = goodname2.gsub("*", "")
			goodname4 = goodname3.gsub("._", ".")
			goodname5 = goodname4.gsub(":", ".")
			goodname6 = goodname5.gsub("..", ".")
			goodname7 = goodname6.gsub("  ", "")
			goodname8 = goodname7.gsub(" ", "")
			goodname9 = goodname8.gsub("._", ".")
			goodname = goodname9.gsub("..", ".")

			UI.message "#####################"
			UI.message "profile.name is " + profile.name
			UI.message "good profile.name is " + goodname
			UI.message "type is " + profile.type
			UI.message "distribution_method is " + profile.distribution_method
			UI.message "profile.id is " + profile.id
			UI.message "#{profile.devices.map(&:id).length} #{profile.name}"
			UI.message "#####################"

			UI.message "Don't add Devices to this Provision Profile " + goodname + " just Downlod"
			output_path = File.join(Sigh.config[:output_path], goodname)
			File.delete(output_path) if File.exist?(output_path)
			File.open(output_path, "wb") do |f|
				f.write(profile.download)
			end

			if profile.type.include? "tvOS"
				UI.message "#####################"
				UI.message "This is iTV Profiles only download this"
				UI.message "#####################"
				p	profile
				p "#{profile.devices.map(&:id).length} #{profile.name}"
				goodname = profile_name.gsub(" ", "_")
				UI.message "Don't add Devices to this Provision Profile " + goodname + " just Downlod"
				output_path = File.join(Sigh.config[:output_path], goodname)
				File.open(output_path, "wb") do |f|
					f.write(profile.download)
				end
			else
				if profile.distribution_method.include? "store"
					p	profile
					goodname = profile_name.gsub(" ", "_")
					UI.message "Don't add Devices to this Provision Profile " + goodname + " just Downlod"
					output_path = File.join(Sigh.config[:output_path], goodname)
					File.open(output_path, "wb") do |f|
						f.write(profile.download)
					end
				else
					UI.message profile
					UI.important "Download the new profile with include all devices"
					profile.devices = Spaceship.device.all_for_profile_type(profile.type)
					p "#{profile.devices.map(&:id).length} #{profile.name}"

					UI.message "Saved Back to Apple"
					goodname = profile_name.gsub(" ", "_")
					UI.message "Download this Provision Profile " + goodname + " with all Devices now"
					output_path = File.join(Sigh.config[:output_path], goodname)
					File.open(output_path, "wb") do |f|
						f.write(profile.download)
					end
				 end
			end

#			Manager.install_profile(output_path) unless Sigh.config[:skip_install]
		end

		def download_profile2(profile)
			FileUtils.mkdir_p(Sigh.config[:output_path])
			profile_name = "#{profile.class.pretty_type}_#{profile.app.bundle_id}.mobileprovision" # default name
			goodname = profile_name.gsub(" ", "_")
			output_path = File.join(Sigh.config[:output_path], goodname)
			File.open(output_path, "wb") do |f|
				f.write(profile.download)
			end

			Manager.install_profile(output_path) unless Sigh.config[:skip_install]
		end
	end
end
