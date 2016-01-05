# NPM dependencies fetcher

Simple sinatra based service to fetch dependencies recursively. It uses Concurrent::Future's for async requests and Concurrent::Map as a storage for futures and results, because they can be modified asynchronously.

```ruby
$ git clone https://github.com/IvanShamatov/fetcher.git
$ cd fetcher
$ bundle install
```

To start server use `shotgun`, and you can touch server with curl like that
``` 
curl http://localhost:9393/[:packet_name]
# example
curl http://localhost:9393/forever
```

Or you can use npm class like that:
```ruby
> require './lib/npm.rb'
> winston = NPM.new('winston')
> winston.all_dependencies
> #=> ["async", "colors", "cycle", "stack-trace", "eyes", "isstream", "pkginfo"]
```

Use `rake test` to run test.

