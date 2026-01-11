package generate_docs

import "core:strings"
import "core:path/filepath"
import "core:os"
import "core:fmt"

import "../update_assets"

main :: proc() {
	exe_path, _ := filepath.abs(os.args[0])
	exe_dir := filepath.dir(exe_path)

	docs_dir := filepath.join({exe_dir, "docs"})

	if !os.exists(docs_dir) {
		os.make_directory(docs_dir)
	}

	LOCALES :: [?]string{
		"en_US",
		"ru_RU",
		// "ua_UA", // barely readable
	}
	LOCALE_DATA_URL_BASE :: "https://gitlab.com/justmc/justmc-localization/-/raw/master/creative_plus/"

	FMT_EVENT_NAME :: "creative_plus.trigger.%s.name"
	FMT_EVENT_DESC :: "creative_plus.trigger.%s.description"
	FMT_EVENT_WORKS_WITH :: "creative_plus.trigger.%s.work_with.%s"
	FMT_EVENT_ADDITIONAL_INFO :: "creative_plus.trigger.%s.additional_information.%s"

	FILE_FLAGS :: os.O_CREATE | os.O_RDWR | os.O_TRUNC

	events_list := update_assets.extract_events()

	for locale in LOCALES {
		translations_raw := update_assets.fetch_url(strings.concatenate({LOCALE_DATA_URL_BASE, locale, ".properties"}))
		t := parse_properties(translations_raw)

		events_file_path := filepath.join({docs_dir, strings.concatenate({"events_", locale, ".md"}) })

		events_fd, err := os.open(events_file_path, FILE_FLAGS)
		if err != nil {
			continue
		}
		defer os.close(events_fd)

		events_title := "Events"
		switch locale {
		case "ru_RU":
			events_title = "События"
		// case "ua_UA":
		// 	events_title = "Події"
		}
		fmt.fprintfln(events_fd, "# %s", events_title)

		works_with := translate(t, "creative_plus.work_with")
		additional_info := translate(t, "creative_plus.additional_information")
		cancellable := translate(t, "creative_plus.trigger.cancellable")

		for event, event_index in events_list {
			name := event.name
			name_localized, has_name := translate(t, FMT_EVENT_NAME, name)
			description_localized, has_description := translate(t, FMT_EVENT_DESC, name)
			if !has_name {
				name_localized = name
			}
			if !has_description {
				description_localized = "..."
			}
			fmt.fprintf(events_fd, "## %s", name_localized)
			if event.cancellable {
				fmt.fprintf(events_fd, " (%s)", cancellable)
			} else {
				fmt.fprint(events_fd)
			}
			fmt.fprintln(events_fd)
			fmt.fprintfln(events_fd, "%s\n```\nevent %s() {{\n\t// Your code here\n}\n```", description_localized, name)
			if len(event.works_with) > 0 {
				fmt.fprintln(events_fd, works_with)
				for item in event.works_with {
					fmt.fprintfln(events_fd, "*\t%s", translate(t, FMT_EVENT_WORKS_WITH, name, item))
				}
			}
			if len(event.additional_info) > 0 {
				fmt.fprintln(events_fd, additional_info)
				for item in event.additional_info {
					fmt.fprintfln(events_fd, "*\t%s", translate(t, FMT_EVENT_ADDITIONAL_INFO, name, item))
				}
			}
			if event_index != len(events_list)-1 {
				fmt.fprintln(events_fd)
			}
		}
	}
}

translate :: proc(t: map[string]string, format: string, args: ..any) -> (string, bool) #optional_ok {
	translated, is_valid := t[fmt.tprintf(format, ..args)]
	if is_valid {
		words := strings.split_multi(translated, {"_", " "})
		for _, word_index in words {
			if word_index == 0 {
				continue
			}
			words[word_index] = strings.to_lower(words[word_index])
			translated = strings.join(words, " ")
		}
	}
	if translated == "" {
		translated = "..."
	}
	return translated, is_valid
}
