from factoriotools/factorio:latest as serverbase


ENV PYTHONUNBUFFERED=1

RUN apk add --update --no-cache --no-progress npm openssh git python3 py3-pip \
   && ln -sf python3 /usr/bin/python \
   && npm install -g n \
   && n stable \
   && npm install typed-factorio luassert-tstl typescript-to-lua typescript lua-types gulp ts-node
# run apt-get update \
#    && apt-get install -y curl git \
#    && rm -rf /var/lib/apt/lists/*
#    && bash ./update_testtorio.sh \

COPY . /opt/workdir/

RUN mkdir -p /factorio/mods /factorio/scenarios /factorio/saves \
   && ln -s /factorio/mods  /opt/factorio/mods \
   && echo '{"mods": [{"name": "base","enabled": true}, {"name": "Testorio", "enabled": true}]}' > /opt/factorio/mods/mod-list.json \
   && cd /opt/workdir/tests \
   && ash ./update_testtorio.sh \
   && cd Testorio \
   && npm install \
   && npm run build:all \
   && cp -r src /factorio/mods/Testorio \
   && cp -r /opt/workdir /factorio/scenarios/Factorio-Biter-Battles
   # && cd luassert \
   # && npm run build \
   # && cd ../ \
   # && npm run build \


# python3 /opt/workdir/tests/factorio_process_manager.py --factorio-exe /opt/factorio/bin/x64/factorio

#     - uses: addnab/docker-run-action@v3
#       with:
#         # TODO: Pin this
#         image: factoriotools/factorio:latest
#         options: -v /opt/factorio:/factorio --entrypoint "/scenario.sh" Factorio-Biter-Battles
