require 'singleton'

# made a singleton verion of ProjectList
# a singleton 

class TM::ProjectList
  attr_reader :projects

  def initialize
    @projects = []
  end

  @@instance = TM::ProjectList.new

  def self.instance
    return @@instance
  end

  def create_project(title)
    proj = TM::Project.new(title)

    @projects << proj

    proj
  end

  def add_task_to_proj(PID, desc, priority)
    proj = @projects.find { |project| project.id == proj_id }

    proj.add_task(desc, priority)

    proj
  end

  # no need to test since so simple
  # def list_projects
  #   @projects
  # end

  # def show_proj_tasks_remaining(PID)
  #   proj = @projects.find { |project| project.id == proj_id }

  #   proj
  # end

  private_class_method :new
end