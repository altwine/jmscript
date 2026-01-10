package update_assets

import "core:fmt"
import "core:encoding/json"
import "core:os"

Particle :: struct {
	id:   int    `json:"id"`,
    name: string `json:"name"`,
}

URL_PARTICLES :: URL_BASE_MC+"particles.json"

extract_particles :: proc() -> [dynamic]Particle {
	particles1 := fetch_url(URL_PARTICLES)
	particles := make([dynamic]Particle)
	err := json.unmarshal(transmute([]byte)particles1, &particles)
	if err != nil {
		return nil
	}

	return particles
}

write_particles :: proc(output_file: string, particles: [dynamic]Particle) {
	fd, _ := os.open(output_file, os.O_CREATE | os.O_RDWR | os.O_TRUNC)
	defer os.close(fd)

	fmt.fprintln(fd, "package assets\n")

	fmt.fprintln(fd, "import \"base:runtime\"\n")

	fmt.fprintln(fd, "Particle :: struct {")
	fmt.fprintln(fd, "\tname: string,")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "particles: map[string]Particle\n")

	fmt.fprintln(fd, "@(init)")
	fmt.fprintln(fd, "init_particles :: proc \"contextless\" () {")
	fmt.fprintln(fd, "\tcontext = runtime.default_context()")
	fmt.fprintln(fd, fmt.tprintf("\tparticles = make(map[string]Particle, %d, context.allocator)", len(particles)))
	for particle in particles {
		fmt.fprintfln(fd, "\tparticles[\"%s\"] = {{\"%s\"}", particle.name, particle.name)
	}
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "@(fini)")
	fmt.fprintln(fd, "cleanup_particles :: proc \"contextless\" () {")
	fmt.fprintln(fd, "\tcontext = runtime.default_context()")
	fmt.fprintln(fd, "\tdelete(particles)")
	fmt.fprintln(fd, "}\n")

	fmt.fprintln(fd, "get_minecraft_particle :: proc(particle_name: string) -> (Particle, bool) {")
	fmt.fprintln(fd, "\treturn particles[particle_name]")
	fmt.fprintln(fd, "}")
}
