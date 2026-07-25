require "csv"

namespace :import_data do
  desc "Import data from CSV file"
  task import_projects: :environment do
    file_path = Rails.root.join("lib", "tasks", "import", "projects.csv")
    stats = { created: 0 }

    katja = User.find_by(username: "Katja")

    CSV.foreach(file_path, headers: true) do |row|
      if row["user_id"] == "12"
        project = Project.create!(id: row["id"], name: row["name"], user: katja)

        stats[:created] += 1
        Log.success("Project created: #{project.name}")
      end
    end
    puts "---"
    Log.success("Projects created: #{stats[:created]}")
  end

  task import_sessions: :environment do
    file_path = Rails.root.join("lib", "tasks", "import", "sessions.csv")
    stats = { created: 0, skipped: 0 }

    katja = User.find_by(username: "Katja")

    CSV.foreach(file_path, headers: true) do |row|
      project = Project.find_by(id: row["project_id"])
      unless project
        stats[:skipped] += 1
        next
      end

      if row["user_id"] == "12"
        session = Session.new(
          id: row["id"],
          description: row["description"],
          duration: row["duration"],
          project: project,
          user: katja
        )

        if row["start_time"].present?
          session.start_time = Time.at(row["start_time"].to_i / 1000.0).utc
        end

        if row["created_at"].present?
          session.created_at = row["created_at"]
        end

        session.save!

        stats[:created] += 1
        Log.success("Session created: #{session.description}")
      end
    end
    puts "---"
    Log.success("Sessions created: #{stats[:created]}")
  end
end

