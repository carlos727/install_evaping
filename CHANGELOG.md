# CHANGELOG

##### Changelog v0.2.0 17/03/2017:

- Add `Tools` module with `get_ips`, `fetch` and `simple_email` functions. The above functions are used in `default.rb` recipe.

- New `default["evaping"]["ip_file"]` and `default["mail"]["to"]` attributes.

- New `ip_file_path` variable of recipe `default.rb` stores value of `default["evaping"]["ip_file"]` attribute.

- Add file `ips.json` and resource `cookbook_file ip_file_path` to manage IPs allocation.
