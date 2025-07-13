#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* concat(const char* s1, const char* s2) {
    if (!s1) return strdup(s2);
    if (!s2) return strdup(s1);
    char* result = malloc(strlen(s1) + strlen(s2) + 1);
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

char* strip_quotes(char* str) {
    while (*str == '[' || *str == '"' || *str == ' ' || *str == '\t') str++;
    char* end = str + strlen(str) - 1;
    while (end > str && (*end == ']' || *end == '"' || *end == ' ' || *end == '\t' || *end == '\n'))
        end--;
    *(end + 1) = '\0';
    return strdup(str);
}

char* create_field(char* name, char* type, char* attrs) {
    char* buffer = malloc(4096);
    buffer[0] = '\0';

    if (strcmp(type, "textarea") == 0) {
        sprintf(buffer,
            "<div>\n  <label>%s:</label><br>\n  <textarea name=\"%s\"%s></textarea>\n</div>\n",
            name, name, attrs);
    } else if (strcmp(type, "dropdown") == 0) {
        char* start = strstr(attrs, "data-options=");
        if (start) {
            char* raw = strchr(start, '=') + 1;
            char* opts = strip_quotes(raw);
            char* token = strtok(opts, ",");
            strcat(buffer, "<div>\n  <label>");
            strcat(buffer, name);
            strcat(buffer, ":</label><br>\n  <select name=\"");
            strcat(buffer, name);
            strcat(buffer, "\"");

            char* clean_attrs = strdup(attrs);
            char* data_opts_pos = strstr(clean_attrs, "data-options=");
            if (data_opts_pos) *data_opts_pos = '\0';
            strcat(buffer, clean_attrs);
            free(clean_attrs);

            strcat(buffer, ">\n");

            while (token) {
                char* clean = strip_quotes(token);
                strcat(buffer, "    <option value=\"");
                strcat(buffer, clean);
                strcat(buffer, "\">");
                strcat(buffer, clean);
                strcat(buffer, "</option>\n");
                token = strtok(NULL, ",");
            }

            strcat(buffer, "  </select>\n</div>\n");
        }
    } else if (strcmp(type, "radio") == 0) {
        char* start = strstr(attrs, "data-options=");
        if (start) {
            char* raw = strchr(start, '=') + 1;
            char* opts = strip_quotes(raw);
            char* token = strtok(opts, ",");
            strcat(buffer, "<div>\n  <label>");
            strcat(buffer, name);
            strcat(buffer, ":</label><br>\n");

            int required = strstr(attrs, "required") != NULL;

            while (token) {
                char* clean = strip_quotes(token);
                strcat(buffer, "  <input type=\"radio\" name=\"");
                strcat(buffer, name);
                strcat(buffer, "\" value=\"");
                strcat(buffer, clean);
                strcat(buffer, "\"");
                if (required) strcat(buffer, " required");
                strcat(buffer, "> ");
                strcat(buffer, clean);
                strcat(buffer, "<br>\n");
                token = strtok(NULL, ",");
            }

            strcat(buffer, "</div>\n");
        }
    } else if (strcmp(type, "checkbox") == 0) {
        sprintf(buffer,
            "<div>\n  <label>%s:</label>\n  <input type=\"checkbox\" name=\"%s\"%s>\n</div>\n",
            name, name, attrs);
    } else {
        sprintf(buffer,
            "<div>\n  <label>%s:</label><br>\n  <input type=\"%s\" name=\"%s\"%s>\n</div>\n",
            name, type, name, attrs);
    }

    return buffer;
}