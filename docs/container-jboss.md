# JBoss Container
The JBoss Container allows servlet 2 and 3 web applications to be run.  These applications are run as the root web application in a JBoss container.

<table>
  <tr>
    <td><strong>Detection Criterion</strong></td><td>Existence of a <tt>WEB-INF/</tt> folder in the application directory and <a href="container-java_main.md">Java Main</a> not detected</td>
  </tr>
  <tr>
    <td><strong>Tags</strong></td>
    <td><tt>jboss=&lang;version&rang;</tt></td>
  </tr>
</table>
Tags are printed to standard output by the buildpack detect script

In order to specify [Spring profiles][], set the [`SPRING_PROFILES_ACTIVE`][] environment variable.  This is automatically detected and used by Spring.

## Configuration
For general information on configuring the buildpack, refer to [Configuration and Extension][].

The container can be configured by modifying the [`config/jboss.yml`][] file in the buildpack fork.  The container uses the [`Repository` utility support][repositories] and so it supports the [version syntax][] defined there.

| Name | Description
| ---- | -----------
| `repository_root` | The URL of the JBoss AS repository index ([details][repositories]).
| `version` | The version of JBoss AS to use. Candidate versions can be found in [this listing][].

[`config/jboss.yml`]: ../config/jboss.yml
[`SPRING_PROFILES_ACTIVE`]: http://docs.spring.io/spring/docs/4.0.0.RELEASE/javadoc-api/org/springframework/core/env/AbstractEnvironment.html#ACTIVE_PROFILES_PROPERTY_NAME
[Configuration and Extension]: ../README.md#configuration-and-extension
[repositories]: extending-repositories.md
[Spring profiles]:http://blog.springsource.com/2011/02/14/spring-3-1-m1-introducing-profile/
[version syntax]: extending-repositories.md#version-syntax-and-ordering
