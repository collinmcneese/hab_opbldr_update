export HAB_LICENSE="accept"
export HAB_ORIGIN='collinmcneese'
# pkg_name = "hab_opbldr_update"
# pkg_origin = "$HAB_ORIGIN"
echo "Installing Habitat"
if [ ! -d /hab ]; then
  curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
fi

# Create `hab` user and group if they do not exist
if getent passwd | grep -q "^hab:" ; then
  echo "Hab user exists, skipping user creation"
else
  useradd hab
fi
hab pkg install core/hab-studio
hab origin key generate

echo "Building package from local plan"
if [ ! -f /tmp/habitat/results/last_build.env ] ; then
  cd /tmp/habitat
  hab pkg build habitat
fi

source /tmp/habitat/results/last_build.env

echo "Installing ${pkg_artifact}"
hab pkg install /tmp/habitat/results/${pkg_artifact}
bootstrapfile='/tmp/habitat/results/bootstrap.json'
echo "{\"bootstrap_mode\": \"true\"}" > ${bootstrapfile}

echo "Determine pkg_prefix for $pkg_artifact"
pkg_prefix=$(find "/hab/pkgs/$pkg_origin/$pkg_name" -maxdepth 2 -mindepth 2 | sort | tail -n 1)
echo "Found: $pkg_prefix"

echo "Running chef for $pkg_name"
cd "$pkg_prefix" || exit 1
hab pkg exec "$pkg_origin/$pkg_name" chef-client -z -c "$pkg_prefix/config/bootstrap-config.rb"

# Cleanup
