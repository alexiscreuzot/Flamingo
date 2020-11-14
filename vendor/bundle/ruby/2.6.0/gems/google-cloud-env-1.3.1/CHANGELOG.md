# Release History

### 1.3.1 / 2020-03-02

#### Bug Fixes

* support faraday 1.x

### 1.3.0 / 2019-10-23

Now requires Ruby 2.4 or later.

#### Features

* Recognize App Engine Standard and Knative

### 1.2.1 / 2019-08-23

#### Bug Fixes

* Send Metadata-Flavor header when testing the metadata server root

#### Documentation

* Update documentation

### 1.2.0 / 2019-06-19

* Support separate timeout for connecting to the metadata server vs the entire request

### 1.1.0 / 2019-05-29

* Support disabling of the metadata cache
* Support configurable retries when querying the metadata server
* Support configuration of the metadata request timeout

### 1.0.5 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 1.0.4 / 2018-09-12

* Add missing documentation files to package.

### 1.0.3 / 2018-09-10

* Update documentation.

### 1.0.2 / 2018-06-28

* Use Kubernetes Engine names.
  * Alias old method names for backwards compatibility.
* Handle EHOSTDOWN error when connecting to env.

### 1.0.1 / 2017-07-11

* Update gem spec homepage links.

### 1.0.0 / 2017-03-31

* Initial release
