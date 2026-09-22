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

The build reads the supplied `booker.db`, renders the templates, and copies
`static/` into `docs/`. Edit CSS, images, and hosting files in `static/`; `docs/`
is generated output and can be recreated from scratch. To preview with Python 3:

```sh
python3 -m http.server 8000 --directory docs
```

Visit <http://localhost:8000/>.

`docs/` is ignored by Git. Commit changes to the database, templates, Perl code,
and `static/`; there is no need to commit a local build.

The [Pages workflow](.github/workflows/pages.yml) tests and builds every push to
`main` and every pull request targeting `main`. Successful pushes to `main`
deploy to GitHub Pages. It can also be run manually from the Actions tab;
manual runs deploy only when run on `main`. Dependencies are installed from
`cpanfile` and cached, using Perl 5.42 on Ubuntu 24.04.

Pages must use **GitHub Actions** as its publishing source (Settings → Pages →
Build and deployment), rather than `main:/docs`. Keep `readabooker.com` as the
custom domain and HTTPS enforcement enabled. With Actions deployments, the
domain is configured in Pages settings; `static/CNAME` remains in the output
for compatibility with other static hosting arrangements. See
[GitHub's custom workflow documentation](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).

Run the regression tests with `prove -v t`. They cover static-asset builds and
winner/shortlist carousel selection and rendering, using temporary output and
test databases so the catalogue and published output remain unchanged.

See [How ReadABooker works](CODEBASE.md) for the architecture, database model,
build instructions, templates, and data-maintenance tools.
