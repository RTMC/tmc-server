require 'spec_helper'

describe "The system (used by an instructor for administration)" do
  include IntegrationTestActions

  before :each do
    visit '/'
    @user = User.create!(:login => 'user', :password => 'xooxer', :administrator => true)
    log_in_as(@user.login)
  end
  
  it "should create a local git repo for new courses by default" do
    create_new_course('mycourse')
    bare_repo_path = Course.repositories_root + '/mycourse.git'
    File.should exist(bare_repo_path)
  end
  
  it "should allow using a remote git repo for new courses" do
    create_bare_repo("#{@test_tmp_dir}/fake_remote_repo")
    
    create_new_course('mycourse', :remote_repo_url => "file://#{@test_tmp_dir}/fake_remote_repo")
    
    bare_repo_path = Course.repositories_root + '/mycourse.git'
    File.should_not exist(bare_repo_path)
    
  end
  
  it "should show all exercises pushed to the course's git repo" do
    create_new_course('mycourse')
    course = Course.find_by_name!('mycourse')
    
    repo = clone_course_repo(course)
    repo.copy_simple_exercise('MyExercise', :deadline => (Date.today - 1.day).to_s)
    repo.add_commit_push
    
    manually_refresh_course('mycourse')
    
    visit '/courses'
    click_link 'mycourse'
    page.should have_content('MyExercise')
  end
end
