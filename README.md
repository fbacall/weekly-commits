# weekly-commits

List your pushed GitHub commits from the last week.

## Requirements

Linux, Ruby, a GitHub account

## Installation

```
git clone https://github.com/fbacall/weekly-commits
cd weekly-commits
cp config.yml.example config.yml
```
Generate a token at https://github.com/settings/tokens with all `repo` scopes.

Edit `config.yml` to include your GitHub username, the generated token, and any email addresses you use on your Git commits.

## Usage

To list your commits from the past week:
```
./commits.rb
```

To list your commits from the past 3 weeks
```
./commits.rb 3
```
etc.
