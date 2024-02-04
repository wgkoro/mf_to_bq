# What is this?

Ruby script generates "Insert SQL file" from MoneyForward CSV.

# Requirements

1. Ruby
1. [direnv](https://github.com/direnv/direnv) *(Optional)
1. [gcloud CLI](https://cloud.google.com/sdk/docs/install) *(Optional)

# Preparation

1. Prepare BiqQuery table
   1. You can find table definition example from `docs/bq_schema.json`
1. Make .envrc file from "envrc" `cp envrc .envrc`
1. Write your BigQuery dataset name, table name to .envrc

# Usage

1. Put MoneyForward CSV file to './app/files/mf.csv'.
1. In the app difrectory, run the following command.

```sh
ruby main.rb
```

or

```sh
make create
```

Then you can find the SQL file(bq.sql) in the './app/files' directory.

# Options

If you have installed gcloud CLI, you can generate SQL file and insert your data to BigQuery with one command.

```sh
# Run ruby script, and insert into BQ table via bq command
make apply
```
# License

MIT License

Copyright (c) 2024 wgkoro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
