# Download zip code areas
# For getting a specific area, use for example &cql_filter=posti_alue='00510'
src/paavo_postialueet.json:
	curl -o $@ "http://geo.stat.fi/geoserver/postialue/wfs?version=2.0.0&request=GetFeature&typeName=postialue:pno_tilasto&srsName=urn:ogc:def:crs:EPSG::4326&outputFormat=json"

# Strip statistics (requires jq)
build/paavo_zipcode_areas_geometry.json: src/paavo_postialueet.json
	jq "{features: [.features[] | {geometry: .geometry, id: .properties.posti_alue, properties: {kunta: .properties.kunta, nimi: .properties.nimi}, type: .type}], type: .type}" < $< > $@

# TopoJSON, no quantization
build/paavo_zipcode_areas_geometry_topo.json: build/paavo_zipcode_areas_geometry.json
	geo2topo -q 0 -o $@ $<

# TopoJSON with simplification
# -f Remove detached rings that are smaller than the simplification threshold after simplifying.
# -S Specify simplification threshold value as the minimum quantile of spherical triangle areas (spherical excess). The value should be in the range [0, 1].
build/paavo_zipcode_areas_geometry_topo_simplified.json: build/paavo_zipcode_areas_geometry_topo.json
	toposimplify -f -S 0.15 -o $@ $<