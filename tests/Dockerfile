from factoriotools/factorio:latest as serverbase

COPY . /opt/workdir/


run mkdir -p /opt/factorio/mods \
   && echo '{"mods": [{"name": "base","enabled": true}, {"name": "Testorio", "enabled": true}]}' >/opt/factorio/mods/mod-list.json \
   && cp /opt/workdir/tests/update_testtorio.sh /opt/factorio/mods \
   && cd /opt/factorio/mods \
   && bash ./update_testtorio.sh \
   && mkdir -p /opt/factorio/scenarios \
   && cd /opt/factorio/scenarios \
   && cp -r /opt/workdir /opt/factorio/scenarios/Factorio-Biter-Battles

    - uses: addnab/docker-run-action@v3
      with:
        # TODO: Pin this
        image: factoriotools/factorio:latest
        options: -v /opt/factorio:/factorio --entrypoint "/scenario.sh" Factorio-Biter-Battles
