SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: f_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
      SELECT public.immutable_unaccent(regdictionary 'public.unaccent', $1)
      $_$;


--
-- Name: immutable_unaccent(regdictionary, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.immutable_unaccent(regdictionary, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/unaccent', 'unaccent_dict';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activities (
    id integer NOT NULL,
    action character varying NOT NULL,
    subject_type character varying,
    subject_id integer,
    author_type character varying,
    author_id integer,
    recipient_type character varying,
    recipient_id integer,
    subject_ip inet NOT NULL,
    admin_activity boolean NOT NULL,
    site_id integer,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activities_id_seq OWNED BY public.activities.id;


--
-- Name: admin_admin_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_admin_groups (
    id bigint NOT NULL,
    site_id bigint,
    name character varying,
    resource_type character varying,
    resource_id bigint,
    group_type integer DEFAULT 0 NOT NULL
);


--
-- Name: admin_admin_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_admin_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_admin_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_admin_groups_id_seq OWNED BY public.admin_admin_groups.id;


--
-- Name: admin_admin_sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_admin_sites (
    id integer NOT NULL,
    admin_id integer,
    site_id integer
);


--
-- Name: admin_admin_sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_admin_sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_admin_sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_admin_sites_id_seq OWNED BY public.admin_admin_sites.id;


--
-- Name: admin_admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_admins (
    id integer NOT NULL,
    email character varying NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    password_digest character varying DEFAULT ''::character varying NOT NULL,
    confirmation_token character varying,
    reset_password_token character varying,
    authorization_level integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_sign_in_at timestamp without time zone,
    last_sign_in_ip inet,
    creation_ip inet,
    god boolean DEFAULT false NOT NULL,
    invitation_token character varying,
    invitation_sent_at timestamp without time zone,
    preview_token character varying NOT NULL
);


--
-- Name: admin_admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_admins_id_seq OWNED BY public.admin_admins.id;


--
-- Name: admin_api_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_api_tokens (
    id bigint NOT NULL,
    admin_id bigint,
    name character varying,
    token character varying,
    "primary" boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    domain character varying
);


--
-- Name: admin_api_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_api_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_api_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_api_tokens_id_seq OWNED BY public.admin_api_tokens.id;


--
-- Name: admin_census_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_census_imports (
    id integer NOT NULL,
    admin_id integer,
    site_id integer,
    imported_records integer DEFAULT 0 NOT NULL,
    completed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_census_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_census_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_census_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_census_imports_id_seq OWNED BY public.admin_census_imports.id;


--
-- Name: admin_group_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_group_permissions (
    id bigint NOT NULL,
    admin_group_id bigint,
    namespace character varying DEFAULT ''::character varying NOT NULL,
    resource_type character varying DEFAULT ''::character varying NOT NULL,
    resource_id bigint,
    action_name character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: admin_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_group_permissions_id_seq OWNED BY public.admin_group_permissions.id;


--
-- Name: admin_groups_admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_groups_admins (
    admin_id bigint NOT NULL,
    admin_group_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_moderations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_moderations (
    id bigint NOT NULL,
    site_id bigint,
    moderable_type character varying,
    moderable_id bigint,
    admin_id bigint,
    stage integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: admin_moderations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_moderations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_moderations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_moderations_id_seq OWNED BY public.admin_moderations.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: census_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_items (
    id integer NOT NULL,
    site_id integer,
    document_number_digest character varying DEFAULT ''::character varying NOT NULL,
    date_of_birth character varying DEFAULT ''::character varying NOT NULL,
    import_reference integer,
    verified boolean DEFAULT false NOT NULL
);


--
-- Name: census_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.census_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: census_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.census_items_id_seq OWNED BY public.census_items.id;


--
-- Name: collection_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_items (
    id bigint NOT NULL,
    item_type character varying,
    item_id bigint,
    container_type character varying,
    container_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    collection_id bigint
);


--
-- Name: collection_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collection_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collection_items_id_seq OWNED BY public.collection_items.id;


--
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collections (
    id bigint NOT NULL,
    site_id bigint,
    title_translations jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    container_type character varying,
    container_id bigint,
    item_type character varying,
    slug character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: collections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collections_id_seq OWNED BY public.collections.id;


--
-- Name: content_block_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_block_fields (
    id integer NOT NULL,
    content_block_id integer,
    field_type integer DEFAULT 0 NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    label text,
    "position" integer DEFAULT 0 NOT NULL
);


--
-- Name: content_block_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_block_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_block_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_block_fields_id_seq OWNED BY public.content_block_fields.id;


--
-- Name: content_block_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_block_records (
    id integer NOT NULL,
    content_block_id integer,
    content_context_type character varying,
    content_context_id integer,
    payload jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_url character varying
);


--
-- Name: content_block_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_block_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_block_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_block_records_id_seq OWNED BY public.content_block_records.id;


--
-- Name: content_blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_blocks (
    id integer NOT NULL,
    site_id integer,
    content_model_name character varying DEFAULT ''::character varying NOT NULL,
    title public.hstore,
    internal_id character varying DEFAULT ''::character varying
);


--
-- Name: content_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_blocks_id_seq OWNED BY public.content_blocks.id;


--
-- Name: custom_field_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_field_records (
    id bigint NOT NULL,
    item_type character varying,
    item_id bigint,
    custom_field_id bigint,
    payload jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: custom_field_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_field_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_field_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_field_records_id_seq OWNED BY public.custom_field_records.id;


--
-- Name: custom_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_fields (
    id bigint NOT NULL,
    site_id bigint,
    class_name character varying,
    "position" integer DEFAULT 0 NOT NULL,
    name_translations jsonb,
    mandatory boolean DEFAULT false,
    field_type integer DEFAULT 0 NOT NULL,
    options jsonb,
    uid character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instance_type character varying,
    instance_id bigint
);


--
-- Name: custom_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_fields_id_seq OWNED BY public.custom_fields.id;


--
-- Name: custom_user_field_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_user_field_records (
    id integer NOT NULL,
    user_id integer,
    custom_user_field_id integer,
    payload jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: custom_user_field_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_user_field_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_user_field_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_user_field_records_id_seq OWNED BY public.custom_user_field_records.id;


--
-- Name: custom_user_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_user_fields (
    id integer NOT NULL,
    site_id integer,
    "position" integer DEFAULT 0 NOT NULL,
    title public.hstore,
    mandatory boolean DEFAULT false,
    field_type integer DEFAULT 0 NOT NULL,
    options jsonb,
    name character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: custom_user_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_user_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_user_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_user_fields_id_seq OWNED BY public.custom_user_fields.id;


--
-- Name: ga_attachings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ga_attachings (
    id bigint NOT NULL,
    site_id integer NOT NULL,
    attachment_id integer NOT NULL,
    attachable_id integer NOT NULL,
    attachable_type character varying NOT NULL
);


--
-- Name: ga_attachings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ga_attachings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ga_attachings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ga_attachings_id_seq OWNED BY public.ga_attachings.id;


--
-- Name: ga_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ga_attachments (
    id bigint NOT NULL,
    site_id integer NOT NULL,
    name character varying,
    description text,
    file_name character varying NOT NULL,
    file_digest character varying NOT NULL,
    url character varying NOT NULL,
    file_size integer NOT NULL,
    current_version integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying DEFAULT ''::character varying NOT NULL,
    collection_id integer,
    archived_at timestamp without time zone
);


--
-- Name: ga_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ga_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ga_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ga_attachments_id_seq OWNED BY public.ga_attachments.id;


--
-- Name: gb_budget_line_feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gb_budget_line_feedbacks (
    id bigint NOT NULL,
    site_id bigint,
    year integer,
    budget_line_id character varying,
    answer1 integer,
    answer2 integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gb_budget_line_feedbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gb_budget_line_feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gb_budget_line_feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gb_budget_line_feedbacks_id_seq OWNED BY public.gb_budget_line_feedbacks.id;


--
-- Name: gb_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gb_categories (
    id bigint NOT NULL,
    site_id integer NOT NULL,
    area_name character varying NOT NULL,
    kind character varying NOT NULL,
    code character varying NOT NULL,
    custom_name_translations jsonb,
    custom_description_translations jsonb
);


--
-- Name: gb_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gb_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gb_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gb_categories_id_seq OWNED BY public.gb_categories.id;


--
-- Name: gbc_consultation_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gbc_consultation_items (
    id integer NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL,
    description text,
    budget_line_id character varying DEFAULT ''::character varying NOT NULL,
    budget_line_amount numeric(12,2) DEFAULT 0.0 NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    consultation_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    budget_line_name character varying DEFAULT ''::character varying NOT NULL,
    block_reduction boolean DEFAULT false
);


--
-- Name: gbc_consultation_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gbc_consultation_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gbc_consultation_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gbc_consultation_items_id_seq OWNED BY public.gbc_consultation_items.id;


--
-- Name: gbc_consultation_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gbc_consultation_responses (
    id integer NOT NULL,
    consultation_id integer,
    consultation_items text,
    budget_amount numeric(12,2) DEFAULT 0.0 NOT NULL,
    visibility_level integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sharing_token character varying,
    document_number_digest character varying,
    user_information jsonb
);


--
-- Name: gbc_consultation_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gbc_consultation_responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gbc_consultation_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gbc_consultation_responses_id_seq OWNED BY public.gbc_consultation_responses.id;


--
-- Name: gbc_consultations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gbc_consultations (
    id integer NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    opens_on date,
    closes_on date,
    visibility_level integer DEFAULT 0 NOT NULL,
    budget_amount numeric(12,2) DEFAULT 0.0 NOT NULL,
    admin_id integer,
    site_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    show_figures boolean DEFAULT true,
    force_responses_balance boolean DEFAULT false
);


--
-- Name: gbc_consultations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gbc_consultations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gbc_consultations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gbc_consultations_id_seq OWNED BY public.gbc_consultations.id;


--
-- Name: gc_calendar_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gc_calendar_configurations (
    id integer NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    collection_id bigint NOT NULL,
    integration_name character varying NOT NULL
);


--
-- Name: gc_calendar_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gc_calendar_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gc_calendar_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gc_calendar_configurations_id_seq OWNED BY public.gc_calendar_configurations.id;


--
-- Name: gc_event_attendees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gc_event_attendees (
    id integer NOT NULL,
    name character varying,
    charge character varying,
    person_id integer,
    event_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gc_event_attendees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gc_event_attendees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gc_event_attendees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gc_event_attendees_id_seq OWNED BY public.gc_event_attendees.id;


--
-- Name: gc_event_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gc_event_locations (
    id integer NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    address character varying,
    lat numeric(10,6),
    lng numeric(10,6),
    event_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gc_event_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gc_event_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gc_event_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gc_event_locations_id_seq OWNED BY public.gc_event_locations.id;


--
-- Name: gc_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gc_events (
    id integer NOT NULL,
    starts_at timestamp without time zone NOT NULL,
    ends_at timestamp without time zone NOT NULL,
    state integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title_translations jsonb,
    description_translations jsonb,
    external_id character varying,
    site_id integer NOT NULL,
    slug character varying NOT NULL,
    collection_id integer,
    archived_at timestamp without time zone,
    description_source_translations jsonb,
    meta jsonb,
    department_id bigint,
    interest_group_id bigint
);


--
-- Name: gc_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gc_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gc_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gc_events_id_seq OWNED BY public.gc_events.id;


--
-- Name: gc_filtering_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gc_filtering_rules (
    id bigint NOT NULL,
    calendar_configuration_id bigint,
    field integer NOT NULL,
    condition integer NOT NULL,
    value character varying NOT NULL,
    action integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    remove_filtering_text boolean DEFAULT false
);


--
-- Name: gc_filtering_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gc_filtering_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gc_filtering_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gc_filtering_rules_id_seq OWNED BY public.gc_filtering_rules.id;


--
-- Name: gcc_charters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gcc_charters (
    id bigint NOT NULL,
    service_id bigint,
    title_translations jsonb,
    slug character varying DEFAULT ''::character varying NOT NULL,
    visibility_level integer DEFAULT 0 NOT NULL,
    "position" integer DEFAULT 999999 NOT NULL,
    archived_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gcc_charters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gcc_charters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gcc_charters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gcc_charters_id_seq OWNED BY public.gcc_charters.id;


--
-- Name: gcc_commitments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gcc_commitments (
    id bigint NOT NULL,
    charter_id bigint,
    title_translations jsonb,
    description_translations jsonb,
    slug character varying DEFAULT ''::character varying NOT NULL,
    visibility_level integer DEFAULT 0 NOT NULL,
    "position" integer DEFAULT 999999 NOT NULL,
    archived_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gcc_commitments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gcc_commitments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gcc_commitments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gcc_commitments_id_seq OWNED BY public.gcc_commitments.id;


--
-- Name: gcc_editions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gcc_editions (
    id bigint NOT NULL,
    commitment_id bigint,
    period_interval integer DEFAULT 0 NOT NULL,
    period timestamp without time zone,
    percentage numeric,
    value numeric,
    max_value numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    archived_at timestamp without time zone
);


--
-- Name: gcc_editions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gcc_editions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gcc_editions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gcc_editions_id_seq OWNED BY public.gcc_editions.id;


--
-- Name: gcc_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gcc_services (
    id bigint NOT NULL,
    site_id bigint,
    title_translations jsonb,
    category_id bigint,
    slug character varying DEFAULT ''::character varying NOT NULL,
    visibility_level integer DEFAULT 0 NOT NULL,
    "position" integer DEFAULT 999999 NOT NULL,
    archived_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gcc_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gcc_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gcc_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gcc_services_id_seq OWNED BY public.gcc_services.id;


--
-- Name: gcms_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gcms_pages (
    id integer NOT NULL,
    site_id integer,
    visibility_level integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title_translations jsonb,
    body_translations jsonb,
    slug character varying DEFAULT ''::character varying NOT NULL,
    collection_id integer,
    body_source_translations jsonb,
    archived_at timestamp without time zone,
    published_on timestamp without time zone NOT NULL,
    template character varying
);


--
-- Name: gcms_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gcms_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gcms_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gcms_pages_id_seq OWNED BY public.gcms_pages.id;


--
-- Name: gcms_section_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gcms_section_items (
    id bigint NOT NULL,
    item_type character varying,
    item_id character varying,
    "position" integer DEFAULT 0 NOT NULL,
    parent_id integer,
    section_id bigint,
    level integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gcms_section_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gcms_section_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gcms_section_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gcms_section_items_id_seq OWNED BY public.gcms_section_items.id;


--
-- Name: gcms_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gcms_sections (
    id bigint NOT NULL,
    title_translations jsonb,
    slug character varying DEFAULT ''::character varying NOT NULL,
    site_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gcms_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gcms_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gcms_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gcms_sections_id_seq OWNED BY public.gcms_sections.id;


--
-- Name: gcore_site_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gcore_site_templates (
    id bigint NOT NULL,
    markup text,
    template_id bigint,
    site_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gcore_site_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gcore_site_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gcore_site_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gcore_site_templates_id_seq OWNED BY public.gcore_site_templates.id;


--
-- Name: gcore_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gcore_templates (
    id bigint NOT NULL,
    template_path character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gcore_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gcore_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gcore_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gcore_templates_id_seq OWNED BY public.gcore_templates.id;


--
-- Name: gdata_datasets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gdata_datasets (
    id bigint NOT NULL,
    site_id bigint,
    name_translations jsonb,
    table_name character varying,
    slug character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_updated_at timestamp without time zone,
    visibility_level integer DEFAULT 0 NOT NULL
);


--
-- Name: gdata_datasets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gdata_datasets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gdata_datasets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gdata_datasets_id_seq OWNED BY public.gdata_datasets.id;


--
-- Name: gdata_favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gdata_favorites (
    id bigint NOT NULL,
    user_id bigint,
    favorited_type character varying,
    favorited_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gdata_favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gdata_favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gdata_favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gdata_favorites_id_seq OWNED BY public.gdata_favorites.id;


--
-- Name: gdata_queries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gdata_queries (
    id bigint NOT NULL,
    dataset_id bigint,
    user_id bigint,
    name_translations jsonb,
    privacy_status integer DEFAULT 0 NOT NULL,
    sql character varying,
    options jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gdata_queries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gdata_queries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gdata_queries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gdata_queries_id_seq OWNED BY public.gdata_queries.id;


--
-- Name: gdata_visualizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gdata_visualizations (
    id bigint NOT NULL,
    query_id bigint,
    user_id bigint,
    name_translations jsonb,
    privacy_status integer DEFAULT 0 NOT NULL,
    spec jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sql character varying,
    dataset_id bigint
);


--
-- Name: gdata_visualizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gdata_visualizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gdata_visualizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gdata_visualizations_id_seq OWNED BY public.gdata_visualizations.id;


--
-- Name: gi_indicators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gi_indicators (
    id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    indicator_response jsonb,
    site_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    year integer
);


--
-- Name: gi_indicators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gi_indicators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gi_indicators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gi_indicators_id_seq OWNED BY public.gi_indicators.id;


--
-- Name: ginv_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ginv_projects (
    id bigint NOT NULL,
    site_id bigint,
    title_translations jsonb,
    external_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ginv_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ginv_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ginv_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ginv_projects_id_seq OWNED BY public.ginv_projects.id;


--
-- Name: gobierto_module_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gobierto_module_settings (
    id integer NOT NULL,
    site_id integer,
    module_name character varying,
    settings jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gobierto_module_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gobierto_module_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gobierto_module_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gobierto_module_settings_id_seq OWNED BY public.gobierto_module_settings.id;


--
-- Name: gp_charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gp_charges (
    id bigint NOT NULL,
    person_id bigint NOT NULL,
    department_id bigint NOT NULL,
    name_translations jsonb,
    start_date date,
    end_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    external_id character varying
);


--
-- Name: gp_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gp_charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gp_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gp_charges_id_seq OWNED BY public.gp_charges.id;


--
-- Name: gp_departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gp_departments (
    id bigint NOT NULL,
    site_id bigint NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL
);


--
-- Name: gp_departments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gp_departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gp_departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gp_departments_id_seq OWNED BY public.gp_departments.id;


--
-- Name: gp_gifts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gp_gifts (
    id bigint NOT NULL,
    person_id bigint NOT NULL,
    name character varying NOT NULL,
    reason character varying,
    meta jsonb,
    date date NOT NULL,
    department_id bigint,
    external_id character varying
);


--
-- Name: gp_gifts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gp_gifts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gp_gifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gp_gifts_id_seq OWNED BY public.gp_gifts.id;


--
-- Name: gp_interest_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gp_interest_groups (
    id bigint NOT NULL,
    site_id bigint NOT NULL,
    name character varying NOT NULL,
    meta jsonb,
    slug character varying NOT NULL
);


--
-- Name: gp_interest_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gp_interest_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gp_interest_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gp_interest_groups_id_seq OWNED BY public.gp_interest_groups.id;


--
-- Name: gp_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gp_invitations (
    id bigint NOT NULL,
    person_id bigint NOT NULL,
    organizer character varying,
    title character varying NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    meta jsonb,
    department_id bigint,
    external_id character varying,
    location jsonb
);


--
-- Name: gp_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gp_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gp_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gp_invitations_id_seq OWNED BY public.gp_invitations.id;


--
-- Name: gp_people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gp_people (
    id integer NOT NULL,
    site_id integer,
    admin_id integer,
    name character varying DEFAULT ''::character varying NOT NULL,
    bio_url character varying,
    visibility_level integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    avatar_url character varying,
    statements_count integer DEFAULT 0 NOT NULL,
    posts_count integer DEFAULT 0 NOT NULL,
    political_group_id integer,
    category integer DEFAULT 0 NOT NULL,
    party integer,
    "position" integer DEFAULT 999999 NOT NULL,
    email character varying,
    charge_translations jsonb,
    bio_translations jsonb,
    slug character varying NOT NULL,
    google_calendar_token character varying,
    bio_source_translations jsonb
);


--
-- Name: gp_people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gp_people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gp_people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gp_people_id_seq OWNED BY public.gp_people.id;


--
-- Name: gp_person_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gp_person_posts (
    id integer NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL,
    body text,
    tags character varying[],
    visibility_level integer DEFAULT 0 NOT NULL,
    person_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    site_id integer NOT NULL,
    slug character varying NOT NULL,
    body_source text
);


--
-- Name: gp_person_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gp_person_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gp_person_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gp_person_posts_id_seq OWNED BY public.gp_person_posts.id;


--
-- Name: gp_person_statements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gp_person_statements (
    id integer NOT NULL,
    published_on date NOT NULL,
    person_id integer,
    visibility_level integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    attachment_url character varying,
    attachment_size integer,
    title_translations jsonb,
    site_id integer NOT NULL,
    slug character varying NOT NULL
);


--
-- Name: gp_person_statements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gp_person_statements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gp_person_statements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gp_person_statements_id_seq OWNED BY public.gp_person_statements.id;


--
-- Name: gp_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gp_settings (
    id integer NOT NULL,
    site_id integer,
    key character varying DEFAULT ''::character varying NOT NULL,
    value character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gp_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gp_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gp_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gp_settings_id_seq OWNED BY public.gp_settings.id;


--
-- Name: gp_trips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gp_trips (
    id bigint NOT NULL,
    person_id bigint NOT NULL,
    title character varying NOT NULL,
    description character varying,
    start_date date NOT NULL,
    end_date date NOT NULL,
    destinations_meta jsonb,
    meta jsonb,
    department_id bigint,
    external_id character varying
);


--
-- Name: gp_trips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gp_trips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gp_trips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gp_trips_id_seq OWNED BY public.gp_trips.id;


--
-- Name: gpart_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpart_comments (
    id bigint NOT NULL,
    body text DEFAULT ''::text NOT NULL,
    commentable_type character varying,
    commentable_id bigint,
    user_id bigint,
    site_id bigint,
    votes_count integer DEFAULT 0,
    flags_count integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    comments_count integer DEFAULT 0
);


--
-- Name: gpart_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gpart_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpart_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gpart_comments_id_seq OWNED BY public.gpart_comments.id;


--
-- Name: gpart_contribution_containers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpart_contribution_containers (
    id bigint NOT NULL,
    title_translations jsonb DEFAULT '""'::jsonb NOT NULL,
    description_translations jsonb DEFAULT '""'::jsonb NOT NULL,
    starts date,
    ends date,
    contribution_type integer DEFAULT 0 NOT NULL,
    visibility_level integer DEFAULT 0 NOT NULL,
    process_id bigint,
    admin_id bigint,
    site_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying DEFAULT ''::character varying NOT NULL,
    visibility_user_level integer DEFAULT 0 NOT NULL,
    archived_at timestamp without time zone
);


--
-- Name: gpart_contribution_containers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gpart_contribution_containers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpart_contribution_containers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gpart_contribution_containers_id_seq OWNED BY public.gpart_contribution_containers.id;


--
-- Name: gpart_contributions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpart_contributions (
    id bigint NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    contribution_container_id bigint,
    user_id bigint,
    site_id bigint,
    votes_count integer DEFAULT 0,
    flags_count integer DEFAULT 0,
    comments_count integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: gpart_contributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gpart_contributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpart_contributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gpart_contributions_id_seq OWNED BY public.gpart_contributions.id;


--
-- Name: gpart_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpart_flags (
    id bigint NOT NULL,
    flaggable_type character varying,
    flaggable_id bigint,
    user_id bigint,
    site_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gpart_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gpart_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpart_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gpart_flags_id_seq OWNED BY public.gpart_flags.id;


--
-- Name: gpart_poll_answer_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpart_poll_answer_templates (
    id bigint NOT NULL,
    question_id bigint NOT NULL,
    text character varying NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    image_url character varying
);


--
-- Name: gpart_poll_answer_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gpart_poll_answer_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpart_poll_answer_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gpart_poll_answer_templates_id_seq OWNED BY public.gpart_poll_answer_templates.id;


--
-- Name: gpart_poll_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpart_poll_answers (
    id bigint NOT NULL,
    poll_id bigint NOT NULL,
    question_id bigint NOT NULL,
    answer_template_id integer,
    text text,
    created_at timestamp without time zone,
    user_id_hmac character varying NOT NULL,
    encrypted_meta text
);


--
-- Name: gpart_poll_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gpart_poll_answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpart_poll_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gpart_poll_answers_id_seq OWNED BY public.gpart_poll_answers.id;


--
-- Name: gpart_poll_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpart_poll_questions (
    id bigint NOT NULL,
    poll_id bigint NOT NULL,
    title_translations jsonb,
    answer_type integer DEFAULT 0 NOT NULL,
    "order" integer DEFAULT 0 NOT NULL
);


--
-- Name: gpart_poll_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gpart_poll_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpart_poll_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gpart_poll_questions_id_seq OWNED BY public.gpart_poll_questions.id;


--
-- Name: gpart_polls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpart_polls (
    id bigint NOT NULL,
    process_id bigint NOT NULL,
    title_translations jsonb,
    description_translations jsonb,
    starts_at date NOT NULL,
    ends_at date NOT NULL,
    visibility_level integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    visibility_user_level integer DEFAULT 0 NOT NULL,
    archived_at timestamp without time zone
);


--
-- Name: gpart_polls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gpart_polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpart_polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gpart_polls_id_seq OWNED BY public.gpart_polls.id;


--
-- Name: gpart_process_stage_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpart_process_stage_pages (
    id bigint NOT NULL,
    process_stage_id bigint NOT NULL,
    page_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gpart_process_stage_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gpart_process_stage_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpart_process_stage_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gpart_process_stage_pages_id_seq OWNED BY public.gpart_process_stage_pages.id;


--
-- Name: gpart_process_stages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpart_process_stages (
    id bigint NOT NULL,
    process_id bigint,
    title_translations jsonb,
    starts date,
    ends date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying NOT NULL,
    stage_type integer DEFAULT 0 NOT NULL,
    description_translations jsonb,
    active boolean DEFAULT false NOT NULL,
    cta_text_translations jsonb,
    "position" integer DEFAULT 999999 NOT NULL,
    menu_translations jsonb,
    cta_description_translations jsonb,
    visibility_level integer DEFAULT 0 NOT NULL
);


--
-- Name: gpart_process_stages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gpart_process_stages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpart_process_stages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gpart_process_stages_id_seq OWNED BY public.gpart_process_stages.id;


--
-- Name: gpart_processes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpart_processes (
    id bigint NOT NULL,
    site_id bigint,
    slug character varying DEFAULT ''::character varying NOT NULL,
    visibility_level integer DEFAULT 0 NOT NULL,
    title_translations jsonb,
    body_translations jsonb,
    starts date,
    ends date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    header_image_url character varying,
    process_type integer DEFAULT 1 NOT NULL,
    issue_id integer,
    scope_id bigint,
    archived_at timestamp without time zone,
    body_source_translations jsonb,
    privacy_status integer DEFAULT 0 NOT NULL
);


--
-- Name: gpart_processes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gpart_processes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpart_processes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gpart_processes_id_seq OWNED BY public.gpart_processes.id;


--
-- Name: gpart_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gpart_votes (
    id bigint NOT NULL,
    votable_type character varying,
    votable_id bigint,
    vote_flag boolean,
    vote_scope character varying,
    vote_weight integer,
    user_id bigint,
    site_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: gpart_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gpart_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gpart_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gpart_votes_id_seq OWNED BY public.gpart_votes.id;


--
-- Name: gplan_categories_nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gplan_categories_nodes (
    category_id integer,
    node_id integer,
    id bigint NOT NULL
);


--
-- Name: gplan_categories_nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gplan_categories_nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gplan_categories_nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gplan_categories_nodes_id_seq OWNED BY public.gplan_categories_nodes.id;


--
-- Name: gplan_nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gplan_nodes (
    id bigint NOT NULL,
    name_translations jsonb,
    progress double precision DEFAULT 0.0,
    starts_at date,
    ends_at date,
    options jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    visibility_level integer DEFAULT 0 NOT NULL,
    admin_id bigint,
    status_id bigint,
    published_version integer,
    "position" integer,
    external_id character varying
);


--
-- Name: gplan_nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gplan_nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gplan_nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gplan_nodes_id_seq OWNED BY public.gplan_nodes.id;


--
-- Name: gplan_plan_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gplan_plan_types (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying DEFAULT ''::character varying NOT NULL,
    name_translations jsonb,
    site_id integer
);


--
-- Name: gplan_plan_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gplan_plan_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gplan_plan_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gplan_plan_types_id_seq OWNED BY public.gplan_plan_types.id;


--
-- Name: gplan_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gplan_plans (
    id bigint NOT NULL,
    title_translations jsonb,
    introduction_translations jsonb,
    year integer,
    configuration_data jsonb,
    plan_type_id bigint,
    site_id bigint,
    slug character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    visibility_level integer DEFAULT 0 NOT NULL,
    css text,
    archived_at timestamp without time zone,
    footer_translations jsonb,
    vocabulary_id bigint,
    statuses_vocabulary_id bigint,
    publish_last_version_automatically boolean DEFAULT false NOT NULL
);


--
-- Name: gplan_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gplan_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gplan_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gplan_plans_id_seq OWNED BY public.gplan_plans.id;


--
-- Name: pg_search_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pg_search_documents (
    id bigint NOT NULL,
    content text,
    searchable_type character varying,
    searchable_id bigint,
    site_id bigint,
    resource_path character varying,
    title_translations jsonb,
    description_translations jsonb,
    meta jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    external_id character varying,
    searchable_updated_at timestamp without time zone,
    content_tsvector tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, public.f_unaccent(COALESCE(content, ''::text)))) STORED
);


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pg_search_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pg_search_documents_id_seq OWNED BY public.pg_search_documents.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sites (
    id integer NOT NULL,
    domain character varying,
    configuration_data text,
    organization_name character varying,
    organization_url character varying,
    organization_type character varying,
    reply_to_email character varying,
    organization_address character varying,
    organization_document_number character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    visibility_level integer DEFAULT 0 NOT NULL,
    creation_ip inet,
    organization_id character varying,
    name_translations jsonb,
    title_translations jsonb
);


--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sites_id_seq OWNED BY public.sites.id;


--
-- Name: terms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.terms (
    id bigint NOT NULL,
    vocabulary_id bigint,
    name_translations jsonb,
    description_translations jsonb,
    slug character varying,
    "position" integer DEFAULT 0 NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    term_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    external_id character varying
);


--
-- Name: terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.terms_id_seq OWNED BY public.terms.id;


--
-- Name: translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.translations (
    id integer NOT NULL,
    locale character varying,
    key character varying,
    value text,
    interpolations text,
    is_proc boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    site_id integer
);


--
-- Name: translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.translations_id_seq OWNED BY public.translations.id;


--
-- Name: user_api_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_api_tokens (
    id bigint NOT NULL,
    user_id bigint,
    name character varying,
    token character varying,
    "primary" boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    domain character varying
);


--
-- Name: user_api_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_api_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_api_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_api_tokens_id_seq OWNED BY public.user_api_tokens.id;


--
-- Name: user_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_notifications (
    id integer NOT NULL,
    user_id integer,
    site_id integer,
    action character varying,
    subject_type character varying,
    subject_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_sent boolean DEFAULT false NOT NULL,
    is_seen boolean DEFAULT false NOT NULL
);


--
-- Name: user_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_notifications_id_seq OWNED BY public.user_notifications.id;


--
-- Name: user_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_subscriptions (
    id integer NOT NULL,
    user_id integer,
    site_id integer,
    subscribable_type character varying,
    subscribable_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_subscriptions_id_seq OWNED BY public.user_subscriptions.id;


--
-- Name: user_verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_verifications (
    id integer NOT NULL,
    user_id integer,
    site_id integer,
    verification_type integer DEFAULT 0 NOT NULL,
    verification_data character varying,
    creation_ip inet,
    version integer DEFAULT 0 NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_verifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_verifications_id_seq OWNED BY public.user_verifications.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying NOT NULL,
    name character varying,
    bio character varying,
    password_digest character varying,
    confirmation_token character varying,
    reset_password_token character varying,
    creation_ip inet,
    last_sign_in_at timestamp without time zone,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    site_id integer,
    census_verified boolean DEFAULT false NOT NULL,
    gender integer,
    notification_frequency integer DEFAULT 0 NOT NULL,
    date_of_birth date,
    referrer_url character varying,
    referrer_entity character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    item_type character varying NOT NULL,
    item_id bigint NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: vocabularies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabularies (
    id bigint NOT NULL,
    site_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name_translations jsonb,
    slug character varying
);


--
-- Name: vocabularies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabularies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabularies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabularies_id_seq OWNED BY public.vocabularies.id;


--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities ALTER COLUMN id SET DEFAULT nextval('public.activities_id_seq'::regclass);


--
-- Name: admin_admin_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_admin_groups ALTER COLUMN id SET DEFAULT nextval('public.admin_admin_groups_id_seq'::regclass);


--
-- Name: admin_admin_sites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_admin_sites ALTER COLUMN id SET DEFAULT nextval('public.admin_admin_sites_id_seq'::regclass);


--
-- Name: admin_admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_admins ALTER COLUMN id SET DEFAULT nextval('public.admin_admins_id_seq'::regclass);


--
-- Name: admin_api_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_api_tokens ALTER COLUMN id SET DEFAULT nextval('public.admin_api_tokens_id_seq'::regclass);


--
-- Name: admin_census_imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_census_imports ALTER COLUMN id SET DEFAULT nextval('public.admin_census_imports_id_seq'::regclass);


--
-- Name: admin_group_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.admin_group_permissions_id_seq'::regclass);


--
-- Name: admin_moderations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_moderations ALTER COLUMN id SET DEFAULT nextval('public.admin_moderations_id_seq'::regclass);


--
-- Name: census_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_items ALTER COLUMN id SET DEFAULT nextval('public.census_items_id_seq'::regclass);


--
-- Name: collection_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_items ALTER COLUMN id SET DEFAULT nextval('public.collection_items_id_seq'::regclass);


--
-- Name: collections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections ALTER COLUMN id SET DEFAULT nextval('public.collections_id_seq'::regclass);


--
-- Name: content_block_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_block_fields ALTER COLUMN id SET DEFAULT nextval('public.content_block_fields_id_seq'::regclass);


--
-- Name: content_block_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_block_records ALTER COLUMN id SET DEFAULT nextval('public.content_block_records_id_seq'::regclass);


--
-- Name: content_blocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_blocks ALTER COLUMN id SET DEFAULT nextval('public.content_blocks_id_seq'::regclass);


--
-- Name: custom_field_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_field_records ALTER COLUMN id SET DEFAULT nextval('public.custom_field_records_id_seq'::regclass);


--
-- Name: custom_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_fields ALTER COLUMN id SET DEFAULT nextval('public.custom_fields_id_seq'::regclass);


--
-- Name: custom_user_field_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_user_field_records ALTER COLUMN id SET DEFAULT nextval('public.custom_user_field_records_id_seq'::regclass);


--
-- Name: custom_user_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_user_fields ALTER COLUMN id SET DEFAULT nextval('public.custom_user_fields_id_seq'::regclass);


--
-- Name: ga_attachings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ga_attachings ALTER COLUMN id SET DEFAULT nextval('public.ga_attachings_id_seq'::regclass);


--
-- Name: ga_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ga_attachments ALTER COLUMN id SET DEFAULT nextval('public.ga_attachments_id_seq'::regclass);


--
-- Name: gb_budget_line_feedbacks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gb_budget_line_feedbacks ALTER COLUMN id SET DEFAULT nextval('public.gb_budget_line_feedbacks_id_seq'::regclass);


--
-- Name: gb_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gb_categories ALTER COLUMN id SET DEFAULT nextval('public.gb_categories_id_seq'::regclass);


--
-- Name: gbc_consultation_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gbc_consultation_items ALTER COLUMN id SET DEFAULT nextval('public.gbc_consultation_items_id_seq'::regclass);


--
-- Name: gbc_consultation_responses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gbc_consultation_responses ALTER COLUMN id SET DEFAULT nextval('public.gbc_consultation_responses_id_seq'::regclass);


--
-- Name: gbc_consultations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gbc_consultations ALTER COLUMN id SET DEFAULT nextval('public.gbc_consultations_id_seq'::regclass);


--
-- Name: gc_calendar_configurations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gc_calendar_configurations ALTER COLUMN id SET DEFAULT nextval('public.gc_calendar_configurations_id_seq'::regclass);


--
-- Name: gc_event_attendees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gc_event_attendees ALTER COLUMN id SET DEFAULT nextval('public.gc_event_attendees_id_seq'::regclass);


--
-- Name: gc_event_locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gc_event_locations ALTER COLUMN id SET DEFAULT nextval('public.gc_event_locations_id_seq'::regclass);


--
-- Name: gc_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gc_events ALTER COLUMN id SET DEFAULT nextval('public.gc_events_id_seq'::regclass);


--
-- Name: gc_filtering_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gc_filtering_rules ALTER COLUMN id SET DEFAULT nextval('public.gc_filtering_rules_id_seq'::regclass);


--
-- Name: gcc_charters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcc_charters ALTER COLUMN id SET DEFAULT nextval('public.gcc_charters_id_seq'::regclass);


--
-- Name: gcc_commitments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcc_commitments ALTER COLUMN id SET DEFAULT nextval('public.gcc_commitments_id_seq'::regclass);


--
-- Name: gcc_editions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcc_editions ALTER COLUMN id SET DEFAULT nextval('public.gcc_editions_id_seq'::regclass);


--
-- Name: gcc_services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcc_services ALTER COLUMN id SET DEFAULT nextval('public.gcc_services_id_seq'::regclass);


--
-- Name: gcms_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcms_pages ALTER COLUMN id SET DEFAULT nextval('public.gcms_pages_id_seq'::regclass);


--
-- Name: gcms_section_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcms_section_items ALTER COLUMN id SET DEFAULT nextval('public.gcms_section_items_id_seq'::regclass);


--
-- Name: gcms_sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcms_sections ALTER COLUMN id SET DEFAULT nextval('public.gcms_sections_id_seq'::regclass);


--
-- Name: gcore_site_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcore_site_templates ALTER COLUMN id SET DEFAULT nextval('public.gcore_site_templates_id_seq'::regclass);


--
-- Name: gcore_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcore_templates ALTER COLUMN id SET DEFAULT nextval('public.gcore_templates_id_seq'::regclass);


--
-- Name: gdata_datasets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gdata_datasets ALTER COLUMN id SET DEFAULT nextval('public.gdata_datasets_id_seq'::regclass);


--
-- Name: gdata_favorites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gdata_favorites ALTER COLUMN id SET DEFAULT nextval('public.gdata_favorites_id_seq'::regclass);


--
-- Name: gdata_queries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gdata_queries ALTER COLUMN id SET DEFAULT nextval('public.gdata_queries_id_seq'::regclass);


--
-- Name: gdata_visualizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gdata_visualizations ALTER COLUMN id SET DEFAULT nextval('public.gdata_visualizations_id_seq'::regclass);


--
-- Name: gi_indicators id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gi_indicators ALTER COLUMN id SET DEFAULT nextval('public.gi_indicators_id_seq'::regclass);


--
-- Name: ginv_projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ginv_projects ALTER COLUMN id SET DEFAULT nextval('public.ginv_projects_id_seq'::regclass);


--
-- Name: gobierto_module_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gobierto_module_settings ALTER COLUMN id SET DEFAULT nextval('public.gobierto_module_settings_id_seq'::regclass);


--
-- Name: gp_charges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_charges ALTER COLUMN id SET DEFAULT nextval('public.gp_charges_id_seq'::regclass);


--
-- Name: gp_departments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_departments ALTER COLUMN id SET DEFAULT nextval('public.gp_departments_id_seq'::regclass);


--
-- Name: gp_gifts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_gifts ALTER COLUMN id SET DEFAULT nextval('public.gp_gifts_id_seq'::regclass);


--
-- Name: gp_interest_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_interest_groups ALTER COLUMN id SET DEFAULT nextval('public.gp_interest_groups_id_seq'::regclass);


--
-- Name: gp_invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_invitations ALTER COLUMN id SET DEFAULT nextval('public.gp_invitations_id_seq'::regclass);


--
-- Name: gp_people id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_people ALTER COLUMN id SET DEFAULT nextval('public.gp_people_id_seq'::regclass);


--
-- Name: gp_person_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_person_posts ALTER COLUMN id SET DEFAULT nextval('public.gp_person_posts_id_seq'::regclass);


--
-- Name: gp_person_statements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_person_statements ALTER COLUMN id SET DEFAULT nextval('public.gp_person_statements_id_seq'::regclass);


--
-- Name: gp_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_settings ALTER COLUMN id SET DEFAULT nextval('public.gp_settings_id_seq'::regclass);


--
-- Name: gp_trips id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_trips ALTER COLUMN id SET DEFAULT nextval('public.gp_trips_id_seq'::regclass);


--
-- Name: gpart_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_comments ALTER COLUMN id SET DEFAULT nextval('public.gpart_comments_id_seq'::regclass);


--
-- Name: gpart_contribution_containers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_contribution_containers ALTER COLUMN id SET DEFAULT nextval('public.gpart_contribution_containers_id_seq'::regclass);


--
-- Name: gpart_contributions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_contributions ALTER COLUMN id SET DEFAULT nextval('public.gpart_contributions_id_seq'::regclass);


--
-- Name: gpart_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_flags ALTER COLUMN id SET DEFAULT nextval('public.gpart_flags_id_seq'::regclass);


--
-- Name: gpart_poll_answer_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_poll_answer_templates ALTER COLUMN id SET DEFAULT nextval('public.gpart_poll_answer_templates_id_seq'::regclass);


--
-- Name: gpart_poll_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_poll_answers ALTER COLUMN id SET DEFAULT nextval('public.gpart_poll_answers_id_seq'::regclass);


--
-- Name: gpart_poll_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_poll_questions ALTER COLUMN id SET DEFAULT nextval('public.gpart_poll_questions_id_seq'::regclass);


--
-- Name: gpart_polls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_polls ALTER COLUMN id SET DEFAULT nextval('public.gpart_polls_id_seq'::regclass);


--
-- Name: gpart_process_stage_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_process_stage_pages ALTER COLUMN id SET DEFAULT nextval('public.gpart_process_stage_pages_id_seq'::regclass);


--
-- Name: gpart_process_stages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_process_stages ALTER COLUMN id SET DEFAULT nextval('public.gpart_process_stages_id_seq'::regclass);


--
-- Name: gpart_processes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_processes ALTER COLUMN id SET DEFAULT nextval('public.gpart_processes_id_seq'::regclass);


--
-- Name: gpart_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_votes ALTER COLUMN id SET DEFAULT nextval('public.gpart_votes_id_seq'::regclass);


--
-- Name: gplan_categories_nodes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gplan_categories_nodes ALTER COLUMN id SET DEFAULT nextval('public.gplan_categories_nodes_id_seq'::regclass);


--
-- Name: gplan_nodes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gplan_nodes ALTER COLUMN id SET DEFAULT nextval('public.gplan_nodes_id_seq'::regclass);


--
-- Name: gplan_plan_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gplan_plan_types ALTER COLUMN id SET DEFAULT nextval('public.gplan_plan_types_id_seq'::regclass);


--
-- Name: gplan_plans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gplan_plans ALTER COLUMN id SET DEFAULT nextval('public.gplan_plans_id_seq'::regclass);


--
-- Name: pg_search_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pg_search_documents ALTER COLUMN id SET DEFAULT nextval('public.pg_search_documents_id_seq'::regclass);


--
-- Name: sites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites ALTER COLUMN id SET DEFAULT nextval('public.sites_id_seq'::regclass);


--
-- Name: terms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.terms ALTER COLUMN id SET DEFAULT nextval('public.terms_id_seq'::regclass);


--
-- Name: translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translations ALTER COLUMN id SET DEFAULT nextval('public.translations_id_seq'::regclass);


--
-- Name: user_api_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_api_tokens ALTER COLUMN id SET DEFAULT nextval('public.user_api_tokens_id_seq'::regclass);


--
-- Name: user_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications ALTER COLUMN id SET DEFAULT nextval('public.user_notifications_id_seq'::regclass);


--
-- Name: user_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.user_subscriptions_id_seq'::regclass);


--
-- Name: user_verifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_verifications ALTER COLUMN id SET DEFAULT nextval('public.user_verifications_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: vocabularies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabularies ALTER COLUMN id SET DEFAULT nextval('public.vocabularies_id_seq'::regclass);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: admin_admin_groups admin_admin_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_admin_groups
    ADD CONSTRAINT admin_admin_groups_pkey PRIMARY KEY (id);


--
-- Name: admin_admin_sites admin_admin_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_admin_sites
    ADD CONSTRAINT admin_admin_sites_pkey PRIMARY KEY (id);


--
-- Name: admin_admins admin_admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_admins
    ADD CONSTRAINT admin_admins_pkey PRIMARY KEY (id);


--
-- Name: admin_api_tokens admin_api_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_api_tokens
    ADD CONSTRAINT admin_api_tokens_pkey PRIMARY KEY (id);


--
-- Name: admin_census_imports admin_census_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_census_imports
    ADD CONSTRAINT admin_census_imports_pkey PRIMARY KEY (id);


--
-- Name: admin_group_permissions admin_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_group_permissions
    ADD CONSTRAINT admin_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: admin_moderations admin_moderations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_moderations
    ADD CONSTRAINT admin_moderations_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: census_items census_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_items
    ADD CONSTRAINT census_items_pkey PRIMARY KEY (id);


--
-- Name: collection_items collection_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_items
    ADD CONSTRAINT collection_items_pkey PRIMARY KEY (id);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: content_block_fields content_block_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_block_fields
    ADD CONSTRAINT content_block_fields_pkey PRIMARY KEY (id);


--
-- Name: content_block_records content_block_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_block_records
    ADD CONSTRAINT content_block_records_pkey PRIMARY KEY (id);


--
-- Name: content_blocks content_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_blocks
    ADD CONSTRAINT content_blocks_pkey PRIMARY KEY (id);


--
-- Name: custom_field_records custom_field_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_field_records
    ADD CONSTRAINT custom_field_records_pkey PRIMARY KEY (id);


--
-- Name: custom_fields custom_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_fields
    ADD CONSTRAINT custom_fields_pkey PRIMARY KEY (id);


--
-- Name: custom_user_field_records custom_user_field_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_user_field_records
    ADD CONSTRAINT custom_user_field_records_pkey PRIMARY KEY (id);


--
-- Name: custom_user_fields custom_user_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_user_fields
    ADD CONSTRAINT custom_user_fields_pkey PRIMARY KEY (id);


--
-- Name: ga_attachings ga_attachings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ga_attachings
    ADD CONSTRAINT ga_attachings_pkey PRIMARY KEY (id);


--
-- Name: ga_attachments ga_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ga_attachments
    ADD CONSTRAINT ga_attachments_pkey PRIMARY KEY (id);


--
-- Name: gb_budget_line_feedbacks gb_budget_line_feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gb_budget_line_feedbacks
    ADD CONSTRAINT gb_budget_line_feedbacks_pkey PRIMARY KEY (id);


--
-- Name: gb_categories gb_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gb_categories
    ADD CONSTRAINT gb_categories_pkey PRIMARY KEY (id);


--
-- Name: gbc_consultation_items gbc_consultation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gbc_consultation_items
    ADD CONSTRAINT gbc_consultation_items_pkey PRIMARY KEY (id);


--
-- Name: gbc_consultation_responses gbc_consultation_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gbc_consultation_responses
    ADD CONSTRAINT gbc_consultation_responses_pkey PRIMARY KEY (id);


--
-- Name: gbc_consultations gbc_consultations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gbc_consultations
    ADD CONSTRAINT gbc_consultations_pkey PRIMARY KEY (id);


--
-- Name: gc_calendar_configurations gc_calendar_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gc_calendar_configurations
    ADD CONSTRAINT gc_calendar_configurations_pkey PRIMARY KEY (id);


--
-- Name: gc_event_attendees gc_event_attendees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gc_event_attendees
    ADD CONSTRAINT gc_event_attendees_pkey PRIMARY KEY (id);


--
-- Name: gc_event_locations gc_event_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gc_event_locations
    ADD CONSTRAINT gc_event_locations_pkey PRIMARY KEY (id);


--
-- Name: gc_events gc_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gc_events
    ADD CONSTRAINT gc_events_pkey PRIMARY KEY (id);


--
-- Name: gc_filtering_rules gc_filtering_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gc_filtering_rules
    ADD CONSTRAINT gc_filtering_rules_pkey PRIMARY KEY (id);


--
-- Name: gcc_charters gcc_charters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcc_charters
    ADD CONSTRAINT gcc_charters_pkey PRIMARY KEY (id);


--
-- Name: gcc_commitments gcc_commitments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcc_commitments
    ADD CONSTRAINT gcc_commitments_pkey PRIMARY KEY (id);


--
-- Name: gcc_editions gcc_editions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcc_editions
    ADD CONSTRAINT gcc_editions_pkey PRIMARY KEY (id);


--
-- Name: gcc_services gcc_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcc_services
    ADD CONSTRAINT gcc_services_pkey PRIMARY KEY (id);


--
-- Name: gcms_pages gcms_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcms_pages
    ADD CONSTRAINT gcms_pages_pkey PRIMARY KEY (id);


--
-- Name: gcms_section_items gcms_section_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcms_section_items
    ADD CONSTRAINT gcms_section_items_pkey PRIMARY KEY (id);


--
-- Name: gcms_sections gcms_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcms_sections
    ADD CONSTRAINT gcms_sections_pkey PRIMARY KEY (id);


--
-- Name: gcore_site_templates gcore_site_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcore_site_templates
    ADD CONSTRAINT gcore_site_templates_pkey PRIMARY KEY (id);


--
-- Name: gcore_templates gcore_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gcore_templates
    ADD CONSTRAINT gcore_templates_pkey PRIMARY KEY (id);


--
-- Name: gdata_datasets gdata_datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gdata_datasets
    ADD CONSTRAINT gdata_datasets_pkey PRIMARY KEY (id);


--
-- Name: gdata_favorites gdata_favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gdata_favorites
    ADD CONSTRAINT gdata_favorites_pkey PRIMARY KEY (id);


--
-- Name: gdata_queries gdata_queries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gdata_queries
    ADD CONSTRAINT gdata_queries_pkey PRIMARY KEY (id);


--
-- Name: gdata_visualizations gdata_visualizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gdata_visualizations
    ADD CONSTRAINT gdata_visualizations_pkey PRIMARY KEY (id);


--
-- Name: gi_indicators gi_indicators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gi_indicators
    ADD CONSTRAINT gi_indicators_pkey PRIMARY KEY (id);


--
-- Name: ginv_projects ginv_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ginv_projects
    ADD CONSTRAINT ginv_projects_pkey PRIMARY KEY (id);


--
-- Name: gobierto_module_settings gobierto_module_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gobierto_module_settings
    ADD CONSTRAINT gobierto_module_settings_pkey PRIMARY KEY (id);


--
-- Name: gp_charges gp_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_charges
    ADD CONSTRAINT gp_charges_pkey PRIMARY KEY (id);


--
-- Name: gp_departments gp_departments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_departments
    ADD CONSTRAINT gp_departments_pkey PRIMARY KEY (id);


--
-- Name: gp_gifts gp_gifts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_gifts
    ADD CONSTRAINT gp_gifts_pkey PRIMARY KEY (id);


--
-- Name: gp_interest_groups gp_interest_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_interest_groups
    ADD CONSTRAINT gp_interest_groups_pkey PRIMARY KEY (id);


--
-- Name: gp_invitations gp_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_invitations
    ADD CONSTRAINT gp_invitations_pkey PRIMARY KEY (id);


--
-- Name: gp_people gp_people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_people
    ADD CONSTRAINT gp_people_pkey PRIMARY KEY (id);


--
-- Name: gp_person_posts gp_person_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_person_posts
    ADD CONSTRAINT gp_person_posts_pkey PRIMARY KEY (id);


--
-- Name: gp_person_statements gp_person_statements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_person_statements
    ADD CONSTRAINT gp_person_statements_pkey PRIMARY KEY (id);


--
-- Name: gp_settings gp_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_settings
    ADD CONSTRAINT gp_settings_pkey PRIMARY KEY (id);


--
-- Name: gp_trips gp_trips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_trips
    ADD CONSTRAINT gp_trips_pkey PRIMARY KEY (id);


--
-- Name: gpart_comments gpart_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_comments
    ADD CONSTRAINT gpart_comments_pkey PRIMARY KEY (id);


--
-- Name: gpart_contribution_containers gpart_contribution_containers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_contribution_containers
    ADD CONSTRAINT gpart_contribution_containers_pkey PRIMARY KEY (id);


--
-- Name: gpart_contributions gpart_contributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_contributions
    ADD CONSTRAINT gpart_contributions_pkey PRIMARY KEY (id);


--
-- Name: gpart_flags gpart_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_flags
    ADD CONSTRAINT gpart_flags_pkey PRIMARY KEY (id);


--
-- Name: gpart_poll_answer_templates gpart_poll_answer_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_poll_answer_templates
    ADD CONSTRAINT gpart_poll_answer_templates_pkey PRIMARY KEY (id);


--
-- Name: gpart_poll_answers gpart_poll_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_poll_answers
    ADD CONSTRAINT gpart_poll_answers_pkey PRIMARY KEY (id);


--
-- Name: gpart_poll_questions gpart_poll_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_poll_questions
    ADD CONSTRAINT gpart_poll_questions_pkey PRIMARY KEY (id);


--
-- Name: gpart_polls gpart_polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_polls
    ADD CONSTRAINT gpart_polls_pkey PRIMARY KEY (id);


--
-- Name: gpart_process_stage_pages gpart_process_stage_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_process_stage_pages
    ADD CONSTRAINT gpart_process_stage_pages_pkey PRIMARY KEY (id);


--
-- Name: gpart_process_stages gpart_process_stages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_process_stages
    ADD CONSTRAINT gpart_process_stages_pkey PRIMARY KEY (id);


--
-- Name: gpart_processes gpart_processes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_processes
    ADD CONSTRAINT gpart_processes_pkey PRIMARY KEY (id);


--
-- Name: gpart_votes gpart_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gpart_votes
    ADD CONSTRAINT gpart_votes_pkey PRIMARY KEY (id);


--
-- Name: gplan_categories_nodes gplan_categories_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gplan_categories_nodes
    ADD CONSTRAINT gplan_categories_nodes_pkey PRIMARY KEY (id);


--
-- Name: gplan_nodes gplan_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gplan_nodes
    ADD CONSTRAINT gplan_nodes_pkey PRIMARY KEY (id);


--
-- Name: gplan_plan_types gplan_plan_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gplan_plan_types
    ADD CONSTRAINT gplan_plan_types_pkey PRIMARY KEY (id);


--
-- Name: gplan_plans gplan_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gplan_plans
    ADD CONSTRAINT gplan_plans_pkey PRIMARY KEY (id);


--
-- Name: pg_search_documents pg_search_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pg_search_documents
    ADD CONSTRAINT pg_search_documents_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: terms terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.terms
    ADD CONSTRAINT terms_pkey PRIMARY KEY (id);


--
-- Name: translations translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translations
    ADD CONSTRAINT translations_pkey PRIMARY KEY (id);


--
-- Name: user_api_tokens user_api_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_api_tokens
    ADD CONSTRAINT user_api_tokens_pkey PRIMARY KEY (id);


--
-- Name: user_notifications user_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_pkey PRIMARY KEY (id);


--
-- Name: user_subscriptions user_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: user_verifications user_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_verifications
    ADD CONSTRAINT user_verifications_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: vocabularies vocabularies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabularies
    ADD CONSTRAINT vocabularies_pkey PRIMARY KEY (id);


--
-- Name: gb_categories_record_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX gb_categories_record_unique_index ON public.gb_categories USING btree (site_id, area_name, kind, code);


--
-- Name: index_activities_on_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_action ON public.activities USING btree (action);


--
-- Name: index_activities_on_admin_activity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_admin_activity ON public.activities USING btree (admin_activity);


--
-- Name: index_activities_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_author_type_and_author_id ON public.activities USING btree (author_type, author_id);


--
-- Name: index_activities_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_created_at ON public.activities USING btree (created_at);


--
-- Name: index_activities_on_recipient_type_and_recipient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_recipient_type_and_recipient_id ON public.activities USING btree (recipient_type, recipient_id);


--
-- Name: index_activities_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_site_id ON public.activities USING btree (site_id);


--
-- Name: index_activities_on_subject_id_and_subject_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_subject_id_and_subject_type ON public.activities USING btree (subject_id, subject_type);


--
-- Name: index_activities_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_subject_type_and_subject_id ON public.activities USING btree (subject_type, subject_id);


--
-- Name: index_admin_admin_groups_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_admin_groups_on_resource_type_and_resource_id ON public.admin_admin_groups USING btree (resource_type, resource_id);


--
-- Name: index_admin_admin_groups_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_admin_groups_on_site_id ON public.admin_admin_groups USING btree (site_id);


--
-- Name: index_admin_admin_sites_on_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_admin_sites_on_admin_id ON public.admin_admin_sites USING btree (admin_id);


--
-- Name: index_admin_admin_sites_on_admin_id_and_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_admin_sites_on_admin_id_and_site_id ON public.admin_admin_sites USING btree (admin_id, site_id);


--
-- Name: index_admin_admin_sites_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_admin_sites_on_site_id ON public.admin_admin_sites USING btree (site_id);


--
-- Name: index_admin_admin_sites_on_site_id_and_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_admin_sites_on_site_id_and_admin_id ON public.admin_admin_sites USING btree (site_id, admin_id);


--
-- Name: index_admin_admins_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_admins_on_confirmation_token ON public.admin_admins USING btree (confirmation_token);


--
-- Name: index_admin_admins_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_admins_on_email ON public.admin_admins USING btree (email);


--
-- Name: index_admin_admins_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_admins_on_invitation_token ON public.admin_admins USING btree (invitation_token);


--
-- Name: index_admin_admins_on_preview_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_admins_on_preview_token ON public.admin_admins USING btree (preview_token);


--
-- Name: index_admin_admins_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_admins_on_reset_password_token ON public.admin_admins USING btree (reset_password_token);


--
-- Name: index_admin_api_tokens_on_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_api_tokens_on_admin_id ON public.admin_api_tokens USING btree (admin_id);


--
-- Name: index_admin_api_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_api_tokens_on_token ON public.admin_api_tokens USING btree (token);


--
-- Name: index_admin_census_imports_on_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_census_imports_on_admin_id ON public.admin_census_imports USING btree (admin_id);


--
-- Name: index_admin_census_imports_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_census_imports_on_site_id ON public.admin_census_imports USING btree (site_id);


--
-- Name: index_admin_group_permissions_on_admin_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_group_permissions_on_admin_group_id ON public.admin_group_permissions USING btree (admin_group_id);


--
-- Name: index_admin_moderations_on_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_moderations_on_admin_id ON public.admin_moderations USING btree (admin_id);


--
-- Name: index_admin_moderations_on_moderable_type_and_moderable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_moderations_on_moderable_type_and_moderable_id ON public.admin_moderations USING btree (moderable_type, moderable_id);


--
-- Name: index_admin_moderations_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_moderations_on_site_id ON public.admin_moderations USING btree (site_id);


--
-- Name: index_admin_permissions_on_admin_group_id_and_fields; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_permissions_on_admin_group_id_and_fields ON public.admin_group_permissions USING btree (admin_group_id, namespace, resource_type, resource_id, action_name);


--
-- Name: index_census_items_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_items_on_site_id ON public.census_items USING btree (site_id);


--
-- Name: index_census_items_on_site_id_and_doc_number_and_birth_verified; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_items_on_site_id_and_doc_number_and_birth_verified ON public.census_items USING btree (site_id, document_number_digest, date_of_birth, verified);


--
-- Name: index_census_items_on_site_id_and_doc_number_and_date_of_birth; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_items_on_site_id_and_doc_number_and_date_of_birth ON public.census_items USING btree (site_id, document_number_digest, date_of_birth);


--
-- Name: index_census_items_on_site_id_and_import_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_items_on_site_id_and_import_reference ON public.census_items USING btree (site_id, import_reference);


--
-- Name: index_collection_items_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_items_on_collection_id ON public.collection_items USING btree (collection_id);


--
-- Name: index_collection_items_on_container_type_and_container_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_items_on_container_type_and_container_id ON public.collection_items USING btree (container_type, container_id);


--
-- Name: index_collection_items_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_items_on_item_type_and_item_id ON public.collection_items USING btree (item_type, item_id);


--
-- Name: index_collections_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_site_id ON public.collections USING btree (site_id);


--
-- Name: index_collections_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collections_on_site_id_and_slug ON public.collections USING btree (site_id, slug);


--
-- Name: index_content_block_fields_on_content_block_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_block_fields_on_content_block_id ON public.content_block_fields USING btree (content_block_id);


--
-- Name: index_content_block_records_on_content_block_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_block_records_on_content_block_id ON public.content_block_records USING btree (content_block_id);


--
-- Name: index_content_block_records_on_content_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_block_records_on_content_context ON public.content_block_records USING btree (content_context_type, content_context_id);


--
-- Name: index_content_block_records_on_payload; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_block_records_on_payload ON public.content_block_records USING gin (payload);


--
-- Name: index_content_blocks_on_content_model_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_blocks_on_content_model_name ON public.content_blocks USING btree (content_model_name);


--
-- Name: index_content_blocks_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_blocks_on_site_id ON public.content_blocks USING btree (site_id);


--
-- Name: index_custom_field_records_on_custom_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_field_records_on_custom_field_id ON public.custom_field_records USING btree (custom_field_id);


--
-- Name: index_custom_field_records_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_field_records_on_item_type_and_item_id ON public.custom_field_records USING btree (item_type, item_id);


--
-- Name: index_custom_field_records_on_payload; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_field_records_on_payload ON public.custom_field_records USING gin (payload);


--
-- Name: index_custom_fields_on_instance_type_and_instance_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_fields_on_instance_type_and_instance_id ON public.custom_fields USING btree (instance_type, instance_id);


--
-- Name: index_custom_fields_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_fields_on_site_id ON public.custom_fields USING btree (site_id);


--
-- Name: index_custom_fields_on_site_id_and_uid_and_class_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_custom_fields_on_site_id_and_uid_and_class_name ON public.custom_fields USING btree (site_id, uid, class_name);


--
-- Name: index_custom_user_field_records_on_custom_user_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_user_field_records_on_custom_user_field_id ON public.custom_user_field_records USING btree (custom_user_field_id);


--
-- Name: index_custom_user_field_records_on_payload; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_user_field_records_on_payload ON public.custom_user_field_records USING gin (payload);


--
-- Name: index_custom_user_field_records_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_user_field_records_on_user_id ON public.custom_user_field_records USING btree (user_id);


--
-- Name: index_custom_user_fields_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_user_fields_on_site_id ON public.custom_user_fields USING btree (site_id);


--
-- Name: index_custom_user_fields_on_site_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_custom_user_fields_on_site_id_and_name ON public.custom_user_fields USING btree (site_id, name);


--
-- Name: index_ga_attachments_on_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ga_attachments_on_archived_at ON public.ga_attachments USING btree (archived_at);


--
-- Name: index_ga_attachments_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ga_attachments_on_site_id_and_slug ON public.ga_attachments USING btree (site_id, slug);


--
-- Name: index_gb_budget_line_feedbacks_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gb_budget_line_feedbacks_on_site_id ON public.gb_budget_line_feedbacks USING btree (site_id);


--
-- Name: index_gbc_consultation_items_on_consultation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gbc_consultation_items_on_consultation_id ON public.gbc_consultation_items USING btree (consultation_id);


--
-- Name: index_gbc_consultation_responses_on_consultation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gbc_consultation_responses_on_consultation_id ON public.gbc_consultation_responses USING btree (consultation_id);


--
-- Name: index_gbc_consultation_responses_on_document_number_digest; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gbc_consultation_responses_on_document_number_digest ON public.gbc_consultation_responses USING btree (consultation_id, document_number_digest);


--
-- Name: index_gbc_consultation_responses_on_sharing_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gbc_consultation_responses_on_sharing_token ON public.gbc_consultation_responses USING btree (sharing_token);


--
-- Name: index_gbc_consultation_responses_on_user_information; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gbc_consultation_responses_on_user_information ON public.gbc_consultation_responses USING gin (user_information);


--
-- Name: index_gbc_consultations_on_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gbc_consultations_on_admin_id ON public.gbc_consultations USING btree (admin_id);


--
-- Name: index_gbc_consultations_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gbc_consultations_on_site_id ON public.gbc_consultations USING btree (site_id);


--
-- Name: index_gc_calendar_configurations_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gc_calendar_configurations_on_collection_id ON public.gc_calendar_configurations USING btree (collection_id);


--
-- Name: index_gc_event_attendees_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gc_event_attendees_on_event_id ON public.gc_event_attendees USING btree (event_id);


--
-- Name: index_gc_event_attendees_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gc_event_attendees_on_person_id ON public.gc_event_attendees USING btree (person_id);


--
-- Name: index_gc_event_locations_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gc_event_locations_on_event_id ON public.gc_event_locations USING btree (event_id);


--
-- Name: index_gc_events_on_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gc_events_on_archived_at ON public.gc_events USING btree (archived_at);


--
-- Name: index_gc_events_on_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gc_events_on_department_id ON public.gc_events USING btree (department_id);


--
-- Name: index_gc_events_on_description_source_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gc_events_on_description_source_translations ON public.gc_events USING gin (description_source_translations);


--
-- Name: index_gc_events_on_description_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gc_events_on_description_translations ON public.gc_events USING gin (description_translations);


--
-- Name: index_gc_events_on_interest_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gc_events_on_interest_group_id ON public.gc_events USING btree (interest_group_id);


--
-- Name: index_gc_events_on_meta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gc_events_on_meta ON public.gc_events USING gin (meta);


--
-- Name: index_gc_events_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gc_events_on_site_id_and_slug ON public.gc_events USING btree (site_id, slug);


--
-- Name: index_gc_events_on_title_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gc_events_on_title_translations ON public.gc_events USING gin (title_translations);


--
-- Name: index_gc_filtering_rules_on_calendar_configuration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gc_filtering_rules_on_calendar_configuration_id ON public.gc_filtering_rules USING btree (calendar_configuration_id);


--
-- Name: index_gcc_charters_on_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcc_charters_on_archived_at ON public.gcc_charters USING btree (archived_at);


--
-- Name: index_gcc_charters_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcc_charters_on_service_id ON public.gcc_charters USING btree (service_id);


--
-- Name: index_gcc_commitments_on_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcc_commitments_on_archived_at ON public.gcc_commitments USING btree (archived_at);


--
-- Name: index_gcc_commitments_on_charter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcc_commitments_on_charter_id ON public.gcc_commitments USING btree (charter_id);


--
-- Name: index_gcc_editions_on_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcc_editions_on_archived_at ON public.gcc_editions USING btree (archived_at);


--
-- Name: index_gcc_editions_on_commitment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcc_editions_on_commitment_id ON public.gcc_editions USING btree (commitment_id);


--
-- Name: index_gcc_services_on_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcc_services_on_archived_at ON public.gcc_services USING btree (archived_at);


--
-- Name: index_gcc_services_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcc_services_on_category_id ON public.gcc_services USING btree (category_id);


--
-- Name: index_gcc_services_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcc_services_on_site_id ON public.gcc_services USING btree (site_id);


--
-- Name: index_gcms_pages_on_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcms_pages_on_archived_at ON public.gcms_pages USING btree (archived_at);


--
-- Name: index_gcms_pages_on_body_source_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcms_pages_on_body_source_translations ON public.gcms_pages USING gin (body_source_translations);


--
-- Name: index_gcms_pages_on_body_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcms_pages_on_body_translations ON public.gcms_pages USING gin (body_translations);


--
-- Name: index_gcms_pages_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcms_pages_on_site_id ON public.gcms_pages USING btree (site_id);


--
-- Name: index_gcms_pages_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gcms_pages_on_site_id_and_slug ON public.gcms_pages USING btree (site_id, slug);


--
-- Name: index_gcms_pages_on_title_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcms_pages_on_title_translations ON public.gcms_pages USING gin (title_translations);


--
-- Name: index_gcms_section_items_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcms_section_items_on_item_type_and_item_id ON public.gcms_section_items USING btree (item_type, item_id);


--
-- Name: index_gcms_section_items_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcms_section_items_on_section_id ON public.gcms_section_items USING btree (section_id);


--
-- Name: index_gcms_sections_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcms_sections_on_site_id ON public.gcms_sections USING btree (site_id);


--
-- Name: index_gcms_sections_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gcms_sections_on_site_id_and_slug ON public.gcms_sections USING btree (site_id, slug);


--
-- Name: index_gcore_site_templates_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcore_site_templates_on_site_id ON public.gcore_site_templates USING btree (site_id);


--
-- Name: index_gcore_site_templates_on_template_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gcore_site_templates_on_template_id ON public.gcore_site_templates USING btree (template_id);


--
-- Name: index_gdata_datasets_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gdata_datasets_on_site_id ON public.gdata_datasets USING btree (site_id);


--
-- Name: index_gdata_favorites_on_favorited_type_and_favorited_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gdata_favorites_on_favorited_type_and_favorited_id ON public.gdata_favorites USING btree (favorited_type, favorited_id);


--
-- Name: index_gdata_favorites_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gdata_favorites_on_user_id ON public.gdata_favorites USING btree (user_id);


--
-- Name: index_gdata_queries_on_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gdata_queries_on_dataset_id ON public.gdata_queries USING btree (dataset_id);


--
-- Name: index_gdata_queries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gdata_queries_on_user_id ON public.gdata_queries USING btree (user_id);


--
-- Name: index_gdata_visualizations_on_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gdata_visualizations_on_dataset_id ON public.gdata_visualizations USING btree (dataset_id);


--
-- Name: index_gdata_visualizations_on_query_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gdata_visualizations_on_query_id ON public.gdata_visualizations USING btree (query_id);


--
-- Name: index_gdata_visualizations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gdata_visualizations_on_user_id ON public.gdata_visualizations USING btree (user_id);


--
-- Name: index_gi_indicators_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gi_indicators_on_site_id ON public.gi_indicators USING btree (site_id);


--
-- Name: index_ginv_projects_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ginv_projects_on_site_id ON public.ginv_projects USING btree (site_id);


--
-- Name: index_gobierto_module_settings_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gobierto_module_settings_on_site_id ON public.gobierto_module_settings USING btree (site_id);


--
-- Name: index_gobierto_module_settings_on_site_id_and_module_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gobierto_module_settings_on_site_id_and_module_name ON public.gobierto_module_settings USING btree (site_id, module_name);


--
-- Name: index_gp_charges_on_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_charges_on_department_id ON public.gp_charges USING btree (department_id);


--
-- Name: index_gp_charges_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_charges_on_person_id ON public.gp_charges USING btree (person_id);


--
-- Name: index_gp_departments_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_departments_on_site_id ON public.gp_departments USING btree (site_id);


--
-- Name: index_gp_departments_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gp_departments_on_site_id_and_slug ON public.gp_departments USING btree (site_id, slug);


--
-- Name: index_gp_gifts_on_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_gifts_on_department_id ON public.gp_gifts USING btree (department_id);


--
-- Name: index_gp_gifts_on_meta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_gifts_on_meta ON public.gp_gifts USING gin (meta);


--
-- Name: index_gp_gifts_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_gifts_on_person_id ON public.gp_gifts USING btree (person_id);


--
-- Name: index_gp_interest_groups_on_meta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_interest_groups_on_meta ON public.gp_interest_groups USING gin (meta);


--
-- Name: index_gp_interest_groups_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_interest_groups_on_site_id ON public.gp_interest_groups USING btree (site_id);


--
-- Name: index_gp_interest_groups_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gp_interest_groups_on_site_id_and_slug ON public.gp_interest_groups USING btree (site_id, slug);


--
-- Name: index_gp_invitations_on_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_invitations_on_department_id ON public.gp_invitations USING btree (department_id);


--
-- Name: index_gp_invitations_on_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_invitations_on_location ON public.gp_invitations USING gin (location);


--
-- Name: index_gp_invitations_on_meta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_invitations_on_meta ON public.gp_invitations USING gin (meta);


--
-- Name: index_gp_invitations_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_invitations_on_person_id ON public.gp_invitations USING btree (person_id);


--
-- Name: index_gp_people_on_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_people_on_admin_id ON public.gp_people USING btree (admin_id);


--
-- Name: index_gp_people_on_bio_source_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_people_on_bio_source_translations ON public.gp_people USING gin (bio_source_translations);


--
-- Name: index_gp_people_on_bio_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_people_on_bio_translations ON public.gp_people USING gin (bio_translations);


--
-- Name: index_gp_people_on_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_people_on_category ON public.gp_people USING btree (category);


--
-- Name: index_gp_people_on_category_and_party; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_people_on_category_and_party ON public.gp_people USING btree (category, party);


--
-- Name: index_gp_people_on_charge_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_people_on_charge_translations ON public.gp_people USING gin (charge_translations);


--
-- Name: index_gp_people_on_google_calendar_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gp_people_on_google_calendar_token ON public.gp_people USING btree (google_calendar_token);


--
-- Name: index_gp_people_on_party; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_people_on_party ON public.gp_people USING btree (party);


--
-- Name: index_gp_people_on_political_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_people_on_political_group_id ON public.gp_people USING btree (political_group_id);


--
-- Name: index_gp_people_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_people_on_site_id ON public.gp_people USING btree (site_id);


--
-- Name: index_gp_people_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gp_people_on_site_id_and_slug ON public.gp_people USING btree (site_id, slug);


--
-- Name: index_gp_person_posts_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_person_posts_on_person_id ON public.gp_person_posts USING btree (person_id);


--
-- Name: index_gp_person_posts_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gp_person_posts_on_site_id_and_slug ON public.gp_person_posts USING btree (site_id, slug);


--
-- Name: index_gp_person_posts_on_tags; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_person_posts_on_tags ON public.gp_person_posts USING gin (tags);


--
-- Name: index_gp_person_statements_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_person_statements_on_person_id ON public.gp_person_statements USING btree (person_id);


--
-- Name: index_gp_person_statements_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gp_person_statements_on_site_id_and_slug ON public.gp_person_statements USING btree (site_id, slug);


--
-- Name: index_gp_person_statements_on_title_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_person_statements_on_title_translations ON public.gp_person_statements USING gin (title_translations);


--
-- Name: index_gp_settings_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_settings_on_site_id ON public.gp_settings USING btree (site_id);


--
-- Name: index_gp_trips_on_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_trips_on_department_id ON public.gp_trips USING btree (department_id);


--
-- Name: index_gp_trips_on_destinations_meta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_trips_on_destinations_meta ON public.gp_trips USING gin (destinations_meta);


--
-- Name: index_gp_trips_on_meta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_trips_on_meta ON public.gp_trips USING gin (meta);


--
-- Name: index_gp_trips_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gp_trips_on_person_id ON public.gp_trips USING btree (person_id);


--
-- Name: index_gpart_comments_on_commentable_type_and_commentable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_comments_on_commentable_type_and_commentable_id ON public.gpart_comments USING btree (commentable_type, commentable_id);


--
-- Name: index_gpart_comments_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_comments_on_site_id ON public.gpart_comments USING btree (site_id);


--
-- Name: index_gpart_comments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_comments_on_user_id ON public.gpart_comments USING btree (user_id);


--
-- Name: index_gpart_contribution_containers_on_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_contribution_containers_on_admin_id ON public.gpart_contribution_containers USING btree (admin_id);


--
-- Name: index_gpart_contribution_containers_on_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_contribution_containers_on_archived_at ON public.gpart_contribution_containers USING btree (archived_at);


--
-- Name: index_gpart_contribution_containers_on_process_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_contribution_containers_on_process_id ON public.gpart_contribution_containers USING btree (process_id);


--
-- Name: index_gpart_contribution_containers_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_contribution_containers_on_site_id ON public.gpart_contribution_containers USING btree (site_id);


--
-- Name: index_gpart_contribution_containers_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gpart_contribution_containers_on_site_id_and_slug ON public.gpart_contribution_containers USING btree (site_id, slug);


--
-- Name: index_gpart_contributions_on_contribution_container_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_contributions_on_contribution_container_id ON public.gpart_contributions USING btree (contribution_container_id);


--
-- Name: index_gpart_contributions_on_description; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_contributions_on_description ON public.gpart_contributions USING btree (description);


--
-- Name: index_gpart_contributions_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_contributions_on_site_id ON public.gpart_contributions USING btree (site_id);


--
-- Name: index_gpart_contributions_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gpart_contributions_on_site_id_and_slug ON public.gpart_contributions USING btree (site_id, slug);


--
-- Name: index_gpart_contributions_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_contributions_on_title ON public.gpart_contributions USING btree (title);


--
-- Name: index_gpart_contributions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_contributions_on_user_id ON public.gpart_contributions USING btree (user_id);


--
-- Name: index_gpart_flags_on_flaggable_type_and_flaggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_flags_on_flaggable_type_and_flaggable_id ON public.gpart_flags USING btree (flaggable_type, flaggable_id);


--
-- Name: index_gpart_flags_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_flags_on_site_id ON public.gpart_flags USING btree (site_id);


--
-- Name: index_gpart_flags_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_flags_on_user_id ON public.gpart_flags USING btree (user_id);


--
-- Name: index_gpart_poll_answer_templates_on_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_poll_answer_templates_on_question_id ON public.gpart_poll_answer_templates USING btree (question_id);


--
-- Name: index_gpart_poll_answers_on_poll_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_poll_answers_on_poll_id ON public.gpart_poll_answers USING btree (poll_id);


--
-- Name: index_gpart_poll_answers_on_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_poll_answers_on_question_id ON public.gpart_poll_answers USING btree (question_id);


--
-- Name: index_gpart_poll_answers_on_user_id_hmac; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_poll_answers_on_user_id_hmac ON public.gpart_poll_answers USING btree (user_id_hmac);


--
-- Name: index_gpart_poll_questions_on_poll_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_poll_questions_on_poll_id ON public.gpart_poll_questions USING btree (poll_id);


--
-- Name: index_gpart_polls_on_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_polls_on_archived_at ON public.gpart_polls USING btree (archived_at);


--
-- Name: index_gpart_polls_on_process_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_polls_on_process_id ON public.gpart_polls USING btree (process_id);


--
-- Name: index_gpart_process_stage_pages_on_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_process_stage_pages_on_page_id ON public.gpart_process_stage_pages USING btree (page_id);


--
-- Name: index_gpart_process_stage_pages_on_process_stage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_process_stage_pages_on_process_stage_id ON public.gpart_process_stage_pages USING btree (process_stage_id);


--
-- Name: index_gpart_process_stages_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_process_stages_on_position ON public.gpart_process_stages USING btree ("position");


--
-- Name: index_gpart_process_stages_on_process_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_process_stages_on_process_id ON public.gpart_process_stages USING btree (process_id);


--
-- Name: index_gpart_process_stages_on_process_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gpart_process_stages_on_process_id_and_slug ON public.gpart_process_stages USING btree (process_id, slug);


--
-- Name: index_gpart_process_stages_on_title_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_process_stages_on_title_translations ON public.gpart_process_stages USING gin (title_translations);


--
-- Name: index_gpart_processes_on_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_processes_on_archived_at ON public.gpart_processes USING btree (archived_at);


--
-- Name: index_gpart_processes_on_body_source_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_processes_on_body_source_translations ON public.gpart_processes USING gin (body_source_translations);


--
-- Name: index_gpart_processes_on_body_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_processes_on_body_translations ON public.gpart_processes USING gin (body_translations);


--
-- Name: index_gpart_processes_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_processes_on_site_id ON public.gpart_processes USING btree (site_id);


--
-- Name: index_gpart_processes_on_site_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gpart_processes_on_site_id_and_slug ON public.gpart_processes USING btree (site_id, slug);


--
-- Name: index_gpart_processes_on_title_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_processes_on_title_translations ON public.gpart_processes USING gin (title_translations);


--
-- Name: index_gpart_votes_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_votes_on_site_id ON public.gpart_votes USING btree (site_id);


--
-- Name: index_gpart_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_votes_on_user_id ON public.gpart_votes USING btree (user_id);


--
-- Name: index_gpart_votes_on_user_id_and_vote_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_votes_on_user_id_and_vote_scope ON public.gpart_votes USING btree (user_id, vote_scope);


--
-- Name: index_gpart_votes_on_votable_id_and_votable_type_and_vote_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_votes_on_votable_id_and_votable_type_and_vote_scope ON public.gpart_votes USING btree (votable_id, votable_type, vote_scope);


--
-- Name: index_gpart_votes_on_votable_type_and_votable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gpart_votes_on_votable_type_and_votable_id ON public.gpart_votes USING btree (votable_type, votable_id);


--
-- Name: index_gplan_categories_nodes_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gplan_categories_nodes_on_category_id ON public.gplan_categories_nodes USING btree (category_id);


--
-- Name: index_gplan_categories_nodes_on_node_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gplan_categories_nodes_on_node_id ON public.gplan_categories_nodes USING btree (node_id);


--
-- Name: index_gplan_nodes_on_admin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gplan_nodes_on_admin_id ON public.gplan_nodes USING btree (admin_id);


--
-- Name: index_gplan_nodes_on_name_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gplan_nodes_on_name_translations ON public.gplan_nodes USING gin (name_translations);


--
-- Name: index_gplan_nodes_on_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gplan_nodes_on_position ON public.gplan_nodes USING btree ("position");


--
-- Name: index_gplan_nodes_on_status_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gplan_nodes_on_status_id ON public.gplan_nodes USING btree (status_id);


--
-- Name: index_gplan_plans_on_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gplan_plans_on_archived_at ON public.gplan_plans USING btree (archived_at);


--
-- Name: index_gplan_plans_on_plan_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gplan_plans_on_plan_type_id ON public.gplan_plans USING btree (plan_type_id);


--
-- Name: index_gplan_plans_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gplan_plans_on_site_id ON public.gplan_plans USING btree (site_id);


--
-- Name: index_gplan_plans_on_statuses_vocabulary_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gplan_plans_on_statuses_vocabulary_id ON public.gplan_plans USING btree (statuses_vocabulary_id);


--
-- Name: index_gplan_plans_on_title_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gplan_plans_on_title_translations ON public.gplan_plans USING gin (title_translations);


--
-- Name: index_gplan_plans_on_vocabulary_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gplan_plans_on_vocabulary_id ON public.gplan_plans USING btree (vocabulary_id);


--
-- Name: index_pg_search_documents_on_content_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pg_search_documents_on_content_tsvector ON public.pg_search_documents USING gin (content_tsvector);


--
-- Name: index_pg_search_documents_on_searchable_type_and_searchable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pg_search_documents_on_searchable_type_and_searchable_id ON public.pg_search_documents USING btree (searchable_type, searchable_id);


--
-- Name: index_pg_search_documents_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pg_search_documents_on_site_id ON public.pg_search_documents USING btree (site_id);


--
-- Name: index_sites_on_domain; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_sites_on_domain ON public.sites USING btree (domain);


--
-- Name: index_sites_on_name_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sites_on_name_translations ON public.sites USING gin (name_translations);


--
-- Name: index_sites_on_title_translations; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sites_on_title_translations ON public.sites USING gin (title_translations);


--
-- Name: index_terms_on_slug_and_vocabulary_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_terms_on_slug_and_vocabulary_id ON public.terms USING btree (slug, vocabulary_id);


--
-- Name: index_terms_on_term_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_terms_on_term_id ON public.terms USING btree (term_id);


--
-- Name: index_terms_on_vocabulary_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_terms_on_vocabulary_id ON public.terms USING btree (vocabulary_id);


--
-- Name: index_translations_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_translations_on_key ON public.translations USING btree (key);


--
-- Name: index_translations_on_locale; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_translations_on_locale ON public.translations USING btree (locale);


--
-- Name: index_user_api_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_api_tokens_on_token ON public.user_api_tokens USING btree (token);


--
-- Name: index_user_api_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_api_tokens_on_user_id ON public.user_api_tokens USING btree (user_id);


--
-- Name: index_user_notifications_on_is_seen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_notifications_on_is_seen ON public.user_notifications USING btree (is_seen);


--
-- Name: index_user_notifications_on_is_sent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_notifications_on_is_sent ON public.user_notifications USING btree (is_sent);


--
-- Name: index_user_notifications_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_notifications_on_site_id ON public.user_notifications USING btree (site_id);


--
-- Name: index_user_notifications_on_subject_and_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_notifications_on_subject_and_site_id ON public.user_notifications USING btree (subject_type, subject_id, site_id);


--
-- Name: index_user_notifications_on_subject_and_site_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_notifications_on_subject_and_site_id_and_user_id ON public.user_notifications USING btree (subject_type, subject_id, site_id, user_id);


--
-- Name: index_user_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_notifications_on_user_id ON public.user_notifications USING btree (user_id);


--
-- Name: index_user_notifications_on_user_id_and_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_notifications_on_user_id_and_site_id ON public.user_notifications USING btree (user_id, site_id);


--
-- Name: index_user_subscriptions_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_subscriptions_on_site_id ON public.user_subscriptions USING btree (site_id);


--
-- Name: index_user_subscriptions_on_subscribable_type_and_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_subscriptions_on_subscribable_type_and_site_id ON public.user_subscriptions USING btree (subscribable_type, site_id);


--
-- Name: index_user_subscriptions_on_type_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_subscriptions_on_type_and_id ON public.user_subscriptions USING btree (subscribable_type, subscribable_id, site_id);


--
-- Name: index_user_subscriptions_on_type_and_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_subscriptions_on_type_and_id_and_user_id ON public.user_subscriptions USING btree (subscribable_type, subscribable_id, site_id, user_id);


--
-- Name: index_user_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_subscriptions_on_user_id ON public.user_subscriptions USING btree (user_id);


--
-- Name: index_user_subscriptions_on_user_id_and_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_subscriptions_on_user_id_and_site_id ON public.user_subscriptions USING btree (user_id, site_id);


--
-- Name: index_user_verifications_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_verifications_on_site_id ON public.user_verifications USING btree (site_id);


--
-- Name: index_user_verifications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_verifications_on_user_id ON public.user_verifications USING btree (user_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email_and_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email_and_site_id ON public.users USING btree (email, site_id);


--
-- Name: index_users_on_notification_frequency; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_notification_frequency ON public.users USING btree (notification_frequency);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_site_id ON public.users USING btree (site_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: index_vocabularies_on_site_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vocabularies_on_site_id ON public.vocabularies USING btree (site_id);


--
-- Name: pg_search_documents_on_content_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pg_search_documents_on_content_idx ON public.pg_search_documents USING gin (content public.gin_trgm_ops);


--
-- Name: record_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX record_unique_index ON public.ga_attachings USING btree (site_id, attachment_id, attachable_id, attachable_type);


--
-- Name: unique_index_gpart_poll_answers_for_fixed_answer_questions; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_index_gpart_poll_answers_for_fixed_answer_questions ON public.gpart_poll_answers USING btree (question_id, user_id_hmac, answer_template_id);


--
-- Name: unique_index_gpart_poll_answers_for_open_answer_questions; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_index_gpart_poll_answers_for_open_answer_questions ON public.gpart_poll_answers USING btree (user_id_hmac, answer_template_id);


--
-- Name: gp_person_statements fk_rails_3f8cdf988b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_person_statements
    ADD CONSTRAINT fk_rails_3f8cdf988b FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: gc_events fk_rails_768e5000ba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gc_events
    ADD CONSTRAINT fk_rails_768e5000ba FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: gc_events fk_rails_dfa5e61877; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gc_events
    ADD CONSTRAINT fk_rails_dfa5e61877 FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: gp_person_posts fk_rails_ed626f3a68; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gp_person_posts
    ADD CONSTRAINT fk_rails_ed626f3a68 FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- Name: translations fk_rails_f7f4029ec4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translations
    ADD CONSTRAINT fk_rails_f7f4029ec4 FOREIGN KEY (site_id) REFERENCES public.sites(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20150411144654'),
('20161103165835'),
('20161107174757'),
('20161109071501'),
('20161109104606'),
('20161109160427'),
('20161110071134'),
('20161111060645'),
('20161111060751'),
('20161111111116'),
('20161114111038'),
('20161114161441'),
('20161114174131'),
('20161116054442'),
('20161117070200'),
('20161118063635'),
('20161121133131'),
('20161122111248'),
('20161122115920'),
('20161124065317'),
('20161125113234'),
('20161125160905'),
('20161125170030'),
('20161127123102'),
('20161203085646'),
('20161206065440'),
('20161208114958'),
('20161214101235'),
('20161214101300'),
('20161214104309'),
('20161214104508'),
('20161216132408'),
('20161219132627'),
('20161221062928'),
('20161221101641'),
('20161222054737'),
('20161222064115'),
('20161222064233'),
('20161222173006'),
('20161222191256'),
('20161222192816'),
('20161222193212'),
('20161229184441'),
('20170103172918'),
('20170104151011'),
('20170105080037'),
('20170109052231'),
('20170109110351'),
('20170109162309'),
('20170113100956'),
('20170113111030'),
('20170113111154'),
('20170113111816'),
('20170114153207'),
('20170116072555'),
('20170131144344'),
('20170201120912'),
('20170213134054'),
('20170215091438'),
('20170216114700'),
('20170216114836'),
('20170222070916'),
('20170222144905'),
('20170224090622'),
('20170301120456'),
('20170301120504'),
('20170302100518'),
('20170302154209'),
('20170304172933'),
('20170312182331'),
('20170322144939'),
('20170410082426'),
('20170410112608'),
('20170411101428'),
('20170411163634'),
('20170412092128'),
('20170412092257'),
('20170412092307'),
('20170412125156'),
('20170417094657'),
('20170418145507'),
('20170419153124'),
('20170420072054'),
('20170420132633'),
('20170424104048'),
('20170428081148'),
('20170509075454'),
('20170509082436'),
('20170509082437'),
('20170509154856'),
('20170509163252'),
('20170509163345'),
('20170510091709'),
('20170516111435'),
('20170519070559'),
('20170522103406'),
('20170530144711'),
('20170602084501'),
('20170602140913'),
('20170605103424'),
('20170622125313'),
('20170703101643'),
('20170703134510'),
('20170703145524'),
('20170703152748'),
('20170703154336'),
('20170703154337'),
('20170711143932'),
('20170712103453'),
('20170713101934'),
('20170718094412'),
('20170718132239'),
('20170718145219'),
('20170719065428'),
('20170719091606'),
('20170719141421'),
('20170720154418'),
('20170720162142'),
('20170721101608'),
('20170721104628'),
('20170725101331'),
('20170725131230'),
('20170726122503'),
('20170728075853'),
('20170729075853'),
('20170729084620'),
('20170729093045'),
('20170731151716'),
('20170802094032'),
('20170802134830'),
('20170807125309'),
('20170807125340'),
('20170807131741'),
('20170807135402'),
('20170814214010'),
('20170820075910'),
('20170820080155'),
('20170820154519'),
('20170820154600'),
('20170821072152'),
('20170825193717'),
('20170915144624'),
('20170920145117'),
('20170929075932'),
('20171002075255'),
('20171003112359'),
('20171006092804'),
('20171009135513'),
('20171012153920'),
('20171019074630'),
('20171025133701'),
('20171030120411'),
('20171115151744'),
('20171116124801'),
('20171119160858'),
('20171120133657'),
('20171121093601'),
('20171121094939'),
('20171123111420'),
('20171127130258'),
('20171128100358'),
('20171128100636'),
('20171218082804'),
('20171218152031'),
('20171220101924'),
('20171226112800'),
('20171227094848'),
('20171227134634'),
('20180109103354'),
('20180110180348'),
('20180111105954'),
('20180111122236'),
('20180115112209'),
('20180118103147'),
('20180119184713'),
('20180123093747'),
('20180124102833'),
('20180125152553'),
('20180126082636'),
('20180201082942'),
('20180218084420'),
('20180221140043'),
('20180226181257'),
('20180305102456'),
('20180319122227'),
('20180326065211'),
('20180409145531'),
('20180516151238'),
('20180516153443'),
('20180516154745'),
('20180517094132'),
('20180517103751'),
('20180517110631'),
('20180517125644'),
('20180517134429'),
('20180517134455'),
('20180517135224'),
('20180521150642'),
('20180521153203'),
('20180522081528'),
('20180522082009'),
('20180522082718'),
('20180601135249'),
('20180607153510'),
('20180607153921'),
('20180607153940'),
('20180614100658'),
('20180614101232'),
('20180628143745'),
('20180628143928'),
('20180703140608'),
('20180709144803'),
('20180713102905'),
('20180713103321'),
('20180713103609'),
('20180713151618'),
('20180716085128'),
('20180716092050'),
('20180716092701'),
('20180728095650'),
('20180731153536'),
('20180731165523'),
('20180801142224'),
('20180808110424'),
('20180808210320'),
('20180907140444'),
('20180910103724'),
('20180911210230'),
('20180912085759'),
('20180912124531'),
('20180917133154'),
('20181001135544'),
('20181001142716'),
('20181010102053'),
('20181018085402'),
('20190214131608'),
('20190311155000'),
('20190311175310'),
('20190311182237'),
('20190311184537'),
('20190327141644'),
('20190401094419'),
('20190408145731'),
('20190415093350'),
('20190510172357'),
('20190516134959'),
('20190516143448'),
('20190517155844'),
('20190518184430'),
('20190528111414'),
('20190603074757'),
('20190708162501'),
('20190709132921'),
('20190709161330'),
('20190710130540'),
('20190722154502'),
('20190808150052'),
('20190930142501'),
('20191114152643'),
('20191212104748'),
('20191212104759'),
('20200103121539'),
('20200110121522'),
('20200113173645'),
('20200117102016'),
('20200129160520'),
('20200214113010'),
('20200304185300'),
('20200309131827'),
('20200309152257'),
('20200323181726'),
('20200327131311'),
('20200421114115'),
('20200423142619'),
('20200515093807'),
('20200520103945'),
('20200601185920'),
('20200713143051'),
('20200715172832'),
('20200722180617'),
('20200723121433'),
('20200809102521'),
('20200910112444'),
('20200915105712'),
('20200915105848'),
('20200915105920'),
('20200921171234');


