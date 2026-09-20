# ReadABooker

A website that encourages people to read novels that were shortlisted
for the Booker Prize.

* [readabooker.com](https://readabooker.com/)

To build, install Perl and cpanminus (`cpanm`), then run from the repository root:

```sh
cpanm --installdeps .
perl bin/build
```

The build is verified on Perl 5.42.3. The application declares a Perl 5.20
language minimum; older interpreters have not been tested, and resolved CPAN
dependencies may require a newer version. Installing dependencies from source
also requires a C compiler and `make` for modules such as the SQLite driver.
The [cpanfile](cpanfile) declares build dependencies; optional data-maintenance
tools have separate requirements described in the codebase guide.

The build reads the supplied `booker.db` and writes to `docs/`. Keep the existing
assets in `docs/` when rebuilding. To preview the output with Python 3:

```sh
python3 -m http.server 8000 --directory docs
```

Visit <http://localhost:8000/>.

See [How ReadABooker works](CODEBASE.md) for the architecture, database model,
build instructions, templates, and data-maintenance tools.
