import datetime
import os
import git


# ----------------------------------------------------------------------------------------------------------------------
def update_time_log():
    print(os.getcwd())
    os.chdir('Script_code')
    with open("time_log.txt", "a") as f:
        f.write(str(datetime.datetime.now()))
    os.chdir("..")


# ----------------------------------------------------------------------------------------------------------------------
# git add commit and push to tableau catalog repo
def push_to_git_repo():
    update_time_log()
    print(os.getcwd())
    repo = git.Repo.init()
    print("git add")
    repo.git.add('--all')
    get_datetime = datetime.datetime.now()
    print("git commit")
    repo.git.commit('-m', 'Commit from Tableau server script, ' + str(get_datetime))
    print("pushing to remote")
    origin = repo.remote(name='origin')
    origin.push()
