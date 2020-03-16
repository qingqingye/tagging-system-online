--
-- PostgreSQL database dump
--

-- Dumped from database version 10.12
-- Dumped by pg_dump version 10.12

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
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- Name: update_points(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_points() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        DECLARE
          user_id INT;
        BEGIN
          IF (TG_OP = 'DELETE') THEN
            SELECT a.user_id FROM annotations_annotation a WHERE a.id = OLD.annotation_id INTO user_id;

            IF (OLD.verified) THEN
                UPDATE users_user u SET points = u.points - 1 WHERE u.id = user_id;
            END IF;
            RETURN OLD;
          ELSIF (TG_OP = 'INSERT') THEN
            SELECT a.user_id FROM annotations_annotation a WHERE a.id = NEW.annotation_id INTO user_id;

            IF (NEW.verified) THEN
              UPDATE users_user u SET points = u.points + 1 WHERE u.id = user_id;
            END IF;
            RETURN NEW;
          ELSIF (TG_OP = 'UPDATE') THEN
            SELECT a.user_id FROM annotations_annotation a WHERE a.id = OLD.annotation_id INTO user_id;

            IF (OLD.verified AND OLD.annotation_id != NEW.annotation_id) THEN
              UPDATE users_user u SET points = u.points - 1 WHERE u.id = user_id;

              SELECT a.user_id FROM annotations_annotation a WHERE a.id = NEW.annotation_id INTO user_id;
            END IF;

            SELECT a.user_id FROM annotations_annotation a WHERE a.id = NEW.annotation_id INTO user_id;

            IF (NEW.verified AND (NOT OLD.verified OR (OLD.annotation_id != NEW.annotation_id))) THEN
              UPDATE users_user u SET points = u.points + 1 WHERE u.id = user_id;
            END IF;

            IF (NOT NEW.verified AND OLD.verified AND OLD.annotation_id = NEW.annotation_id) THEN
              UPDATE users_user u SET points = u.points - 1 WHERE u.id = user_id;
            END IF;

            RETURN NEW;
          END IF;
        END
        $$;


ALTER FUNCTION public.update_points() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: annotations_annotation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.annotations_annotation (
    id integer NOT NULL,
    closed boolean NOT NULL,
    "time" timestamp with time zone NOT NULL,
    last_edit_time timestamp with time zone NOT NULL,
    image_id integer NOT NULL,
    last_editor_id integer,
    annotation_type_id integer NOT NULL,
    user_id integer,
    vector jsonb,
    _blurred boolean NOT NULL,
    _concealed boolean NOT NULL
);


ALTER TABLE public.annotations_annotation OWNER TO postgres;

--
-- Name: annotations_annotation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.annotations_annotation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.annotations_annotation_id_seq OWNER TO postgres;

--
-- Name: annotations_annotation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.annotations_annotation_id_seq OWNED BY public.annotations_annotation.id;


--
-- Name: annotations_annotationtype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.annotations_annotationtype (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    active boolean NOT NULL,
    node_count integer NOT NULL,
    vector_type integer NOT NULL,
    enable_blurred boolean NOT NULL,
    enable_concealed boolean NOT NULL,
    "L0" character varying(100) NOT NULL,
    "L1code" integer NOT NULL,
    "L1name" character varying(100) NOT NULL,
    "L2code" character varying(100) NOT NULL
);


ALTER TABLE public.annotations_annotationtype OWNER TO postgres;

--
-- Name: annotations_annotationtype_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.annotations_annotationtype_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.annotations_annotationtype_id_seq OWNER TO postgres;

--
-- Name: annotations_annotationtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.annotations_annotationtype_id_seq OWNED BY public.annotations_annotationtype.id;


--
-- Name: annotations_export; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.annotations_export (
    id integer NOT NULL,
    "time" timestamp with time zone NOT NULL,
    annotation_count integer NOT NULL,
    export_text text NOT NULL,
    image_set_id integer NOT NULL,
    user_id integer,
    format_id integer,
    filename text NOT NULL
);


ALTER TABLE public.annotations_export OWNER TO postgres;

--
-- Name: annotations_export_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.annotations_export_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.annotations_export_id_seq OWNER TO postgres;

--
-- Name: annotations_export_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.annotations_export_id_seq OWNED BY public.annotations_export.id;


--
-- Name: annotations_exportformat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.annotations_exportformat (
    id integer NOT NULL,
    name character varying(20) NOT NULL,
    public boolean NOT NULL,
    base_format text NOT NULL,
    annotation_format text NOT NULL,
    team_id integer NOT NULL,
    not_in_image_format text NOT NULL,
    min_verifications integer NOT NULL,
    image_aggregation boolean NOT NULL,
    image_format text,
    name_format character varying(200) NOT NULL,
    vector_format text NOT NULL,
    last_change_time timestamp with time zone NOT NULL,
    include_blurred boolean NOT NULL,
    include_concealed boolean NOT NULL
);


ALTER TABLE public.annotations_exportformat OWNER TO postgres;

--
-- Name: annotations_exportformat_annotations_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.annotations_exportformat_annotations_types (
    id integer NOT NULL,
    exportformat_id integer NOT NULL,
    annotationtype_id integer NOT NULL
);


ALTER TABLE public.annotations_exportformat_annotations_types OWNER TO postgres;

--
-- Name: annotations_exportformat_annotations_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.annotations_exportformat_annotations_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.annotations_exportformat_annotations_types_id_seq OWNER TO postgres;

--
-- Name: annotations_exportformat_annotations_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.annotations_exportformat_annotations_types_id_seq OWNED BY public.annotations_exportformat_annotations_types.id;


--
-- Name: annotations_exportformat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.annotations_exportformat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.annotations_exportformat_id_seq OWNER TO postgres;

--
-- Name: annotations_exportformat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.annotations_exportformat_id_seq OWNED BY public.annotations_exportformat.id;


--
-- Name: annotations_verification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.annotations_verification (
    id integer NOT NULL,
    "time" timestamp with time zone NOT NULL,
    verified boolean NOT NULL,
    annotation_id integer NOT NULL,
    user_id integer
);


ALTER TABLE public.annotations_verification OWNER TO postgres;

--
-- Name: annotations_verification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.annotations_verification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.annotations_verification_id_seq OWNER TO postgres;

--
-- Name: annotations_verification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.annotations_verification_id_seq OWNED BY public.annotations_verification.id;


--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_id_seq OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_group_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_permissions_id_seq OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_permission_id_seq OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_admin_log_id_seq OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_content_type_id_seq OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO postgres;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_migrations_id_seq OWNER TO postgres;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO postgres;

--
-- Name: images_image; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.images_image (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    filename character varying(100) NOT NULL,
    "time" timestamp with time zone NOT NULL,
    checksum bytea NOT NULL,
    image_set_id integer NOT NULL,
    height integer NOT NULL,
    width integer NOT NULL
);


ALTER TABLE public.images_image OWNER TO postgres;

--
-- Name: images_image_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.images_image_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.images_image_id_seq OWNER TO postgres;

--
-- Name: images_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.images_image_id_seq OWNED BY public.images_image.id;


--
-- Name: images_imageset; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.images_imageset (
    id integer NOT NULL,
    path character varying(100),
    name character varying(100) NOT NULL,
    location character varying(100),
    description text,
    "time" timestamp with time zone NOT NULL,
    public boolean NOT NULL,
    image_lock boolean NOT NULL,
    team_id integer,
    public_collaboration boolean NOT NULL,
    main_annotation_type_id integer,
    priority integer NOT NULL,
    creator_id integer,
    zip_state integer NOT NULL
);


ALTER TABLE public.images_imageset OWNER TO postgres;

--
-- Name: images_imageset_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.images_imageset_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.images_imageset_id_seq OWNER TO postgres;

--
-- Name: images_imageset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.images_imageset_id_seq OWNED BY public.images_imageset.id;


--
-- Name: images_imageset_pinned_by; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.images_imageset_pinned_by (
    id integer NOT NULL,
    imageset_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.images_imageset_pinned_by OWNER TO postgres;

--
-- Name: images_imageset_pinned_by_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.images_imageset_pinned_by_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.images_imageset_pinned_by_id_seq OWNER TO postgres;

--
-- Name: images_imageset_pinned_by_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.images_imageset_pinned_by_id_seq OWNED BY public.images_imageset_pinned_by.id;


--
-- Name: images_settag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.images_settag (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.images_settag OWNER TO postgres;

--
-- Name: images_settag_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.images_settag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.images_settag_id_seq OWNER TO postgres;

--
-- Name: images_settag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.images_settag_id_seq OWNED BY public.images_settag.id;


--
-- Name: images_settag_imagesets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.images_settag_imagesets (
    id integer NOT NULL,
    settag_id integer NOT NULL,
    imageset_id integer NOT NULL
);


ALTER TABLE public.images_settag_imagesets OWNER TO postgres;

--
-- Name: images_settag_imagesets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.images_settag_imagesets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.images_settag_imagesets_id_seq OWNER TO postgres;

--
-- Name: images_settag_imagesets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.images_settag_imagesets_id_seq OWNED BY public.images_settag_imagesets.id;


--
-- Name: tagger_messages_globalmessage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tagger_messages_globalmessage (
    message_ptr_id integer NOT NULL,
    team_admins_only boolean NOT NULL,
    staff_only boolean NOT NULL
);


ALTER TABLE public.tagger_messages_globalmessage OWNER TO postgres;

--
-- Name: tagger_messages_message; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tagger_messages_message (
    id integer NOT NULL,
    title character varying(100) NOT NULL,
    content text NOT NULL,
    creation_time timestamp with time zone NOT NULL,
    start_time timestamp with time zone NOT NULL,
    expire_time timestamp with time zone NOT NULL,
    creator_id integer
);


ALTER TABLE public.tagger_messages_message OWNER TO postgres;

--
-- Name: tagger_messages_message_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tagger_messages_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tagger_messages_message_id_seq OWNER TO postgres;

--
-- Name: tagger_messages_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tagger_messages_message_id_seq OWNED BY public.tagger_messages_message.id;


--
-- Name: tagger_messages_message_read_by; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tagger_messages_message_read_by (
    id integer NOT NULL,
    message_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.tagger_messages_message_read_by OWNER TO postgres;

--
-- Name: tagger_messages_message_read_by_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tagger_messages_message_read_by_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tagger_messages_message_read_by_id_seq OWNER TO postgres;

--
-- Name: tagger_messages_message_read_by_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tagger_messages_message_read_by_id_seq OWNED BY public.tagger_messages_message_read_by.id;


--
-- Name: tagger_messages_teammessage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tagger_messages_teammessage (
    message_ptr_id integer NOT NULL,
    admins_only boolean NOT NULL,
    team_id integer NOT NULL
);


ALTER TABLE public.tagger_messages_teammessage OWNER TO postgres;

--
-- Name: tools_tool; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tools_tool (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    filename character varying(255),
    description text NOT NULL,
    creation_date timestamp with time zone NOT NULL,
    creator_id integer,
    team_id integer,
    public boolean NOT NULL
);


ALTER TABLE public.tools_tool OWNER TO postgres;

--
-- Name: tools_tool_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tools_tool_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tools_tool_id_seq OWNER TO postgres;

--
-- Name: tools_tool_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tools_tool_id_seq OWNED BY public.tools_tool.id;


--
-- Name: tools_toolvote; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tools_toolvote (
    id integer NOT NULL,
    "time" timestamp with time zone NOT NULL,
    positive boolean NOT NULL,
    tool_id integer NOT NULL,
    user_id integer
);


ALTER TABLE public.tools_toolvote OWNER TO postgres;

--
-- Name: tools_toolvote_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tools_toolvote_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tools_toolvote_id_seq OWNER TO postgres;

--
-- Name: tools_toolvote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tools_toolvote_id_seq OWNED BY public.tools_toolvote.id;


--
-- Name: users_team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_team (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    website character varying(100) NOT NULL
);


ALTER TABLE public.users_team OWNER TO postgres;

--
-- Name: users_team_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_team_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_team_id_seq OWNER TO postgres;

--
-- Name: users_team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_team_id_seq OWNED BY public.users_team.id;


--
-- Name: users_teammembership; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_teammembership (
    id integer NOT NULL,
    is_admin boolean NOT NULL,
    team_id integer NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.users_teammembership OWNER TO postgres;

--
-- Name: users_teammembership_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_teammembership_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_teammembership_id_seq OWNER TO postgres;

--
-- Name: users_teammembership_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_teammembership_id_seq OWNED BY public.users_teammembership.id;


--
-- Name: users_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL,
    points integer NOT NULL
);


ALTER TABLE public.users_user OWNER TO postgres;

--
-- Name: users_user_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.users_user_groups OWNER TO postgres;

--
-- Name: users_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_user_groups_id_seq OWNER TO postgres;

--
-- Name: users_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_groups_id_seq OWNED BY public.users_user_groups.id;


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users_user.id;


--
-- Name: users_user_user_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.users_user_user_permissions OWNER TO postgres;

--
-- Name: users_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_user_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_user_user_permissions_id_seq OWNER TO postgres;

--
-- Name: users_user_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_user_permissions_id_seq OWNED BY public.users_user_user_permissions.id;


--
-- Name: annotations_annotation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_annotation ALTER COLUMN id SET DEFAULT nextval('public.annotations_annotation_id_seq'::regclass);


--
-- Name: annotations_annotationtype id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_annotationtype ALTER COLUMN id SET DEFAULT nextval('public.annotations_annotationtype_id_seq'::regclass);


--
-- Name: annotations_export id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_export ALTER COLUMN id SET DEFAULT nextval('public.annotations_export_id_seq'::regclass);


--
-- Name: annotations_exportformat id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_exportformat ALTER COLUMN id SET DEFAULT nextval('public.annotations_exportformat_id_seq'::regclass);


--
-- Name: annotations_exportformat_annotations_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_exportformat_annotations_types ALTER COLUMN id SET DEFAULT nextval('public.annotations_exportformat_annotations_types_id_seq'::regclass);


--
-- Name: annotations_verification id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_verification ALTER COLUMN id SET DEFAULT nextval('public.annotations_verification_id_seq'::regclass);


--
-- Name: auth_group id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);


--
-- Name: auth_group_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);


--
-- Name: auth_permission id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);


--
-- Name: django_admin_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);


--
-- Name: django_content_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);


--
-- Name: django_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);


--
-- Name: images_image id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_image ALTER COLUMN id SET DEFAULT nextval('public.images_image_id_seq'::regclass);


--
-- Name: images_imageset id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_imageset ALTER COLUMN id SET DEFAULT nextval('public.images_imageset_id_seq'::regclass);


--
-- Name: images_imageset_pinned_by id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_imageset_pinned_by ALTER COLUMN id SET DEFAULT nextval('public.images_imageset_pinned_by_id_seq'::regclass);


--
-- Name: images_settag id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_settag ALTER COLUMN id SET DEFAULT nextval('public.images_settag_id_seq'::regclass);


--
-- Name: images_settag_imagesets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_settag_imagesets ALTER COLUMN id SET DEFAULT nextval('public.images_settag_imagesets_id_seq'::regclass);


--
-- Name: tagger_messages_message id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagger_messages_message ALTER COLUMN id SET DEFAULT nextval('public.tagger_messages_message_id_seq'::regclass);


--
-- Name: tagger_messages_message_read_by id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagger_messages_message_read_by ALTER COLUMN id SET DEFAULT nextval('public.tagger_messages_message_read_by_id_seq'::regclass);


--
-- Name: tools_tool id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tools_tool ALTER COLUMN id SET DEFAULT nextval('public.tools_tool_id_seq'::regclass);


--
-- Name: tools_toolvote id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tools_toolvote ALTER COLUMN id SET DEFAULT nextval('public.tools_toolvote_id_seq'::regclass);


--
-- Name: users_team id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_team ALTER COLUMN id SET DEFAULT nextval('public.users_team_id_seq'::regclass);


--
-- Name: users_teammembership id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_teammembership ALTER COLUMN id SET DEFAULT nextval('public.users_teammembership_id_seq'::regclass);


--
-- Name: users_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user ALTER COLUMN id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: users_user_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_groups ALTER COLUMN id SET DEFAULT nextval('public.users_user_groups_id_seq'::regclass);


--
-- Name: users_user_user_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.users_user_user_permissions_id_seq'::regclass);


--
-- Data for Name: annotations_annotation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.annotations_annotation (id, closed, "time", last_edit_time, image_id, last_editor_id, annotation_type_id, user_id, vector, _blurred, _concealed) FROM stdin;
9	f	2020-03-14 23:08:06.046615+08	2020-03-14 23:08:06.046615+08	9	\N	29	1	{"x1": 173, "x2": 487, "y1": 150, "y2": 459}	f	f
10	f	2020-03-14 23:10:10.521152+08	2020-03-14 23:10:10.521152+08	9	\N	365	1	{"x1": 178, "x2": 516, "y1": 165, "y2": 536}	f	f
\.


--
-- Data for Name: annotations_annotationtype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.annotations_annotationtype (id, name, active, node_count, vector_type, enable_blurred, enable_concealed, "L0", "L1code", "L1name", "L2code") FROM stdin;
1	Plain blouse 01a	t	0	1	t	t	Product	1	BLOUSE	01a
2	Cropped blouse 01b	t	0	1	t	t	Product	1	BLOUSE	01b
3	Off the shoulder blouse 01c	t	0	1	t	t	Product	1	BLOUSE	01c
4	Ruffle blouse 01d	t	0	1	t	t	Product	1	BLOUSE	01d
5	Bow blouse 01d2	t	0	1	t	t	Product	1	BLOUSE	01d2
6	Embroidered blouse 01d3	t	0	1	t	t	Product	1	BLOUSE	01d3
7	Scarf blouse 01d4	t	0	1	t	t	Product	1	BLOUSE	01d4
8	Prints&patterns blouse 01f	t	0	1	t	t	Product	1	BLOUSE	01f
9	Plain shirt 01g	t	0	1	t	t	Product	1	BLOUSE Shirt	01g
10	Asymmetric shirt 01h	t	0	1	t	t	Product	1	BLOUSE Shirt	01h
11	Military shirt 01h1	t	0	1	t	t	Product	1	BLOUSE Shirt	01h1
12	White shirt 01h2	t	0	1	t	t	Product	1	BLOUSE Shirt	01h2
13	Occasion shirt 01h3	t	0	1	t	t	Product	1	BLOUSE Shirt	01h3
14	Sleeveless shirt 01i	t	0	1	t	t	Product	1	BLOUSE Shirt	01i
15	Dress shirt > mini 01j	t	0	1	t	t	Product	1	BLOUSE Shirt	01j
16	Tunic 01k	t	0	1	t	t	Product	1	BLOUSE Shirt	01k
17	Over shirts 01l	t	0	1	t	t	Product	1	BLOUSE Shirt	01l
18	Long shirt 01m1	t	0	1	t	t	Product	1	BLOUSE Shirt	01m1
19	Crop shirt 01m2	t	0	1	t	t	Product	1	BLOUSE Shirt	01m2
20	Flap pockets shirt 01n1	t	0	1	t	t	Product	1	BLOUSE Shirt	01n1
21	Patched pockets shirt 01n2	t	0	1	t	t	Product	1	BLOUSE Shirt	01n2
22	Denim shirt 01o	t	0	1	t	t	Product	1	BLOUSE Shirt	01o
23	Leather shirt 01p	t	0	1	t	t	Product	1	BLOUSE Shirt	01p
24	Prints&patterns shirt 01q1	t	0	1	t	t	Product	1	BLOUSE Shirt	01q1
25	Checks&stripes shirt 01q2	t	0	1	t	t	Product	1	BLOUSE Shirt	01q2
26	Tank top 02a	t	0	1	t	t	Product	2	TOP	02a
27	Crop top 02a1	t	0	1	t	t	Product	2	TOP	02a1
28	Evening top 02b	t	0	1	t	t	Product	2	TOP	02b
29	Peplum top 02b1	t	0	1	t	t	Product	2	TOP	02b1
30	Halter top 02b2	t	0	1	t	t	Product	2	TOP	02b2
31	Pajama top 02b4	t	0	1	t	t	Product	2	TOP	02b4
32	Sleeveless top 02c	t	0	1	t	t	Product	2	TOP	02c
33	Fine straps top 02d	t	0	1	t	t	Product	2	TOP	02d
34	Off the shoulder top 02d1	t	0	1	t	t	Product	2	TOP	02d1
35	Single sleeve top 02f	t	0	1	t	t	Product	2	TOP	02f
36	Long sleeves top 02g	t	0	1	t	t	Product	2	TOP	02g
37	Cropped t-shirt 02h	t	0	1	t	t	Product	2	TOP T-shirt	02h
38	T shirt 02h1	t	0	1	t	t	Product	2	TOP T-shirt	02h1
39	Sleeveless t-shirt 02i	t	0	1	t	t	Product	2	TOP T-shirt	02i
40	Long sleeves t-shirt 02j	t	0	1	t	t	Product	2	TOP T-shirt	02j
41	Prints&patterns t-shirt 02k1	t	0	1	t	t	Product	2	TOP T-shirt	02k1
42	Placed pattern t-shirt 02k2	t	0	1	t	t	Product	2	TOP T-shirt	02k2
43	Contrasted trims t-shirt 02k3	t	0	1	t	t	Product	2	TOP T-shirt	02k3
44	Buttoned t-shirt 02k4	t	0	1	t	t	Product	2	TOP T-shirt	02k4
45	Polo 02l	t	0	1	t	t	Product	2	TOP T-shirt	02l
46	Sweatshirt 02m	t	0	1	t	t	Product	2	TOP Sweatshirt 	02m
47	Hoodie 02n	t	0	1	t	t	Product	2	TOP Sweatshirt 	02n
48	Sleeveless top 03a	t	0	1	t	t	Product	3	KNITWEAR top	03a
49	Cardigan 03b	t	0	1	t	t	Product	3	KNITWEAR cardigan	03b
50	Cardigan > short 03b1	t	0	1	t	t	Product	3	KNITWEAR cardigan	03b1
51	Cardigan > long 03b2	t	0	1	t	t	Product	3	KNITWEAR cardigan	03b2
52	Wrap cardigan 03b3	t	0	1	t	t	Product	3	KNITWEAR cardigan	03b3
53	Twinset 03c	t	0	1	t	t	Product	3	KNITWEAR cardigan	03c
54	Sweater 03c1	t	0	1	t	t	Product	3	KNITWEAR sweater	03c1
55	Asymmetric sweater 03d	t	0	1	t	t	Product	3	KNITWEAR sweater	03d
56	Long sweater 03d1	t	0	1	t	t	Product	3	KNITWEAR sweater	03d1
57	Round neck sweater 03f1	t	0	1	t	t	Product	3	KNITWEAR sweater	03f1
58	V neck sweater 03f2	t	0	1	t	t	Product	3	KNITWEAR sweater	03f2
59	High neck sweater 03f3	t	0	1	t	t	Product	3	KNITWEAR sweater	03f3
60	Geometric sweater 03g1	t	0	1	t	t	Product	3	KNITWEAR sweater	03g1
61	Striped sweater 03g2	t	0	1	t	t	Product	3	KNITWEAR sweater	03g2
62	Jacquard sweater 03g3	t	0	1	t	t	Product	3	KNITWEAR sweater	03g3
63	Cable stitch sweater 03g4	t	0	1	t	t	Product	3	KNITWEAR sweater	03g4
64	Mesh sweater 03g5	t	0	1	t	t	Product	3	KNITWEAR sweater	03g5
65	Ribs sweater 03g6	t	0	1	t	t	Product	3	KNITWEAR sweater	03g6
66	Fancy yarns sweater 03h	t	0	1	t	t	Product	3	KNITWEAR sweater	03h
67	Hoodie 03i	t	0	1	t	t	Product	3	KNITWEAR sweater	03i
68	Fleece 03i1	t	0	1	t	t	Product	3	KNITWEAR sweater	03i1
69	Poncho 03j	t	0	1	t	t	Product	3	KNITWEAR poncho	03j
70	Knit skirt 03k	t	0	1	t	t	Product	3	KNITWEAR skirt	03k
71	Knit dress > long 03l1	t	0	1	t	t	Product	3	KNITWEAR dress	03l1
72	Knit dress > mini 03l3	t	0	1	t	t	Product	3	KNITWEAR dress	03l3
73	Knit trousers 03m	t	0	1	t	t	Product	3	KNITWEAR trousers	03m
74	Short 04a	t	0	1	t	t	Product	4	SHORT	04a
75	Short > short 04a1	t	0	1	t	t	Product	4	SHORT	04a1
76	Short > knee length 04a2	t	0	1	t	t	Product	4	SHORT	04a2
77	Short > long length 04a3	t	0	1	t	t	Product	4	SHORT	04a3
78	Cargo short 04b	t	0	1	t	t	Product	4	SHORT	04b
79	Bermuda 04c	t	0	1	t	t	Product	4	SHORT	04c
80	Fluid short 04c1	t	0	1	t	t	Product	4	SHORT	04c1
81	Jogging short 04c2	t	0	1	t	t	Product	4	SHORT	04c2
82	Denim short 04d	t	0	1	t	t	Product	4	SHORT	04d
83	Leather short 04d1	t	0	1	t	t	Product	4	SHORT	04d1
84	Prints&patterns short 04f1	t	0	1	t	t	Product	4	SHORT	04f1
85	Checks&stripes short 04f2	t	0	1	t	t	Product	4	SHORT	04f2
86	Bloomers 05a	t	0	1	t	t	Product	5	TROUSERS	05a
87	Trousers pants 05a1	t	0	1	t	t	Product	5	TROUSERS	05a1
88	Cargo pants 05b	t	0	1	t	t	Product	5	TROUSERS	05b
89	Chino 05c	t	0	1	t	t	Product	5	TROUSERS	05c
90	Jodhpur 05c1	t	0	1	t	t	Product	5	TROUSERS	05c1
91	Jogging pants 05c2	t	0	1	t	t	Product	5	TROUSERS	05c2
92	Crop pants 05d	t	0	1	t	t	Product	5	TROUSERS	05d
93	Darts trousers 05d1	t	0	1	t	t	Product	5	TROUSERS	05d1
94	Fitted trousers 05f	t	0	1	t	t	Product	5	TROUSERS	05f
95	Flared trousers 05g	t	0	1	t	t	Product	5	TROUSERS	05g
96	Side stripes trousers 05h	t	0	1	t	t	Product	5	TROUSERS	05h
97	Straight trousers 05i	t	0	1	t	t	Product	5	TROUSERS	05i
98	Tailored trousers 05j	t	0	1	t	t	Product	5	TROUSERS	05j
99	Wide legs trousers 05k	t	0	1	t	t	Product	5	TROUSERS	05k
100	Leggings 05l	t	0	1	t	t	Product	5	TROUSERS	05l
101	High waist trousers 05m1	t	0	1	t	t	Product	5	TROUSERS	05m1
102	Drawstring trousers 05m2	t	0	1	t	t	Product	5	TROUSERS	05m2
103	Fancy belt trousers 05m3	t	0	1	t	t	Product	5	TROUSERS	05m3
104	Belted trousers 05m4	t	0	1	t	t	Product	5	TROUSERS	05m4
105	Leather pants 05n	t	0	1	t	t	Product	5	TROUSERS	05n
106	Prints&patterns trousers 05o1	t	0	1	t	t	Product	5	TROUSERS	05o1
107	Checks&stripes trousers 05o2	t	0	1	t	t	Product	5	TROUSERS	05o2
108	Boyfriend jeans 06a	t	0	1	t	t	Product	6	JEANS	06a
109	Cargo jeans 06b	t	0	1	t	t	Product	6	JEANS	06b
110	Crop jeans 06c	t	0	1	t	t	Product	6	JEANS	06c
111	Fitted jeans 06d	t	0	1	t	t	Product	6	JEANS	06d
112	Skinny jeans 06d1	t	0	1	t	t	Product	6	JEANS	06d1
113	Loose jeans 06d3	t	0	1	t	t	Product	6	JEANS	06d3
114	Recomposed jeans 06f	t	0	1	t	t	Product	6	JEANS	06f
115	Straight legs 06g	t	0	1	t	t	Product	6	JEANS	06g
116	Wide legs trousers 06h	t	0	1	t	t	Product	6	JEANS	06h
117	Boot cut jeans 06h1	t	0	1	t	t	Product	6	JEANS	06h1
118	Denim jumpsuit 06h2	t	0	1	t	t	Product	6	JEANS	06h2
119	Vintage jeans 06h3	t	0	1	t	t	Product	6	JEANS	06h3
120	Zipped leg jeans 06i	t	0	1	t	t	Product	6	JEANS	06i
121	High waist jeans 06j1	t	0	1	t	t	Product	6	JEANS	06j1
122	Low waist jeans 06j2	t	0	1	t	t	Product	6	JEANS	06j2
123	Distressed jeans 06k	t	0	1	t	t	Product	6	JEANS	06k
124	Black jeans 06l1	t	0	1	t	t	Product	6	JEANS	06l1
125	Bleached jeans 06l2	t	0	1	t	t	Product	6	JEANS	06l2
126	Stone washed jeans 06l3	t	0	1	t	t	Product	6	JEANS	06l3
127	Indigo jeans 06l4	t	0	1	t	t	Product	6	JEANS	06l4
128	Skirt > long 07a1	t	0	1	t	t	Product	7	SKIRT	07a1     
129	Skirt > midi 07a2	t	0	1	t	t	Product	7	SKIRT	07a2
130	Skirt > mini 07a3	t	0	1	t	t	Product	7	SKIRT	07a3
131	Puffy skirt > mini 07b3	t	0	1	t	t	Product	7	SKIRT	07b3
132	Ruffles skirt > mini 07c3	t	0	1	t	t	Product	7	SKIRT	07c3
133	Short skirt skort 07d	t	0	1	t	t	Product	7	SKIRT	07d
134	Skirt pants 07d2	t	0	1	t	t	Product	7	SKIRT	07d2
135	Overskirt 07d3	t	0	1	t	t	Product	7	SKIRT	07d3
136	Pareo 07d4	t	0	1	t	t	Product	7	SKIRT	07d4
137	Crinoline 07d5	t	0	1	t	t	Product	7	SKIRT	07d5
138	Wrap skirt 07d8	t	0	1	t	t	Product	7	SKIRT	07d8
139	Wrap skirt > long 07d81	t	0	1	t	t	Product	7	SKIRT	07d81
140	A line skirt 07d9	t	0	1	t	t	Product	7	SKIRT	07d9
141	Fringed skirt 07d10	t	0	1	t	t	Product	7	SKIRT	07d10
142	Drape skirt > midi 07d11	t	0	1	t	t	Product	7	SKIRT	07d11
143	Pencil skirt > long 07f1	t	0	1	t	t	Product	7	SKIRT	07f1
144	Pencil skirt > midi 07f2	t	0	1	t	t	Product	7	SKIRT	07f2
145	Zipped skirt > midi 07g2	t	0	1	t	t	Product	7	SKIRT	07g2
146	Asymmetric skirt > long 07h1	t	0	1	t	t	Product	7	SKIRT	07h1
147	Buttoned skirt > long 07i1	t	0	1	t	t	Product	7	SKIRT	07i1
148	Fitted skirt > long 07j1	t	0	1	t	t	Product	7	SKIRT	07j1
149	Flared skirt > long 07k1	t	0	1	t	t	Product	7	SKIRT	07k1
150	Flared skirt > mini 07k3	t	0	1	t	t	Product	7	SKIRT	07k3
151	Pleated skirt > long 07l1	t	0	1	t	t	Product	7	SKIRT	07l1
152	Slit skirt > long 07m1	t	0	1	t	t	Product	7	SKIRT	07m1
153	Denim skirt 07n1	t	0	1	t	t	Product	7	SKIRT	07n1
154	Leather skirt 07n2	t	0	1	t	t	Product	7	SKIRT	07n2
155	Knitted skirt 07n3	t	0	1	t	t	Product	7	SKIRT	07n3
156	Prints&patterns skirt 07o1	t	0	1	t	t	Product	7	SKIRT	07o1
157	Checks&stripes skirt 07o2	t	0	1	t	t	Product	7	SKIRT	07o2
158	Belted dress 08a	t	0	1	t	t	Product	8	DRESS	08a
159	Dress 08a1	t	0	1	t	t	Product	8	DRESS	08a1
160	Asymmetric dress 08b	t	0	1	t	t	Product	8	DRESS	08b
161	Puffy dress 08c	t	0	1	t	t	Product	8	DRESS	08c
162	Ruffles dress 08d	t	0	1	t	t	Product	8	DRESS	08d
163	T shirt dress 08d1	t	0	1	t	t	Product	8	DRESS	08d1
164	Jacket dress 08d2	t	0	1	t	t	Product	8	DRESS	08d2
165	Little black dress 08d3	t	0	1	t	t	Product	8	DRESS	08d3
166	Collared shift dress 08d4	t	0	1	t	t	Product	8	DRESS	08d4
167	Occasion dress 08d5	t	0	1	t	t	Product	8	DRESS	08d5
168	Empire line dress 08d6	t	0	1	t	t	Product	8	DRESS	08d6
169	Mini dress 08d7	t	0	1	t	t	Product	8	DRESS	08d7
170	Traditional dress 08d8	t	0	1	t	t	Product	8	DRESS	08d8
171	Wrapper dress 08d9	t	0	1	t	t	Product	8	DRESS	08d9
172	Prairie dress 08d11	t	0	1	t	t	Product	8	DRESS	08d11
173	A line dress 08d12	t	0	1	t	t	Product	8	DRESS	08d12
174	Pinafore dress 08d13	t	0	1	t	t	Product	8	DRESS	08d13
175	Halter dress 08d14	t	0	1	t	t	Product	8	DRESS	08d14
176	Boxy dress  >  mini 08f3	t	0	1	t	t	Product	8	DRESS	08f3
177	Dress shirt  >  long 08g1	t	0	1	t	t	Product	8	DRESS	08g1
178	Dress shirt  >  midi 08g2	t	0	1	t	t	Product	8	DRESS	08g2
179	Dress shirt  >  mini 08g3	t	0	1	t	t	Product	8	DRESS	08g3
180	Fitted dress  >  long 08h1	t	0	1	t	t	Product	8	DRESS	08h1
181	Fitted dress  >  midi 08h2	t	0	1	t	t	Product	8	DRESS	08h2
182	Fitted dress  >  mini 08h3	t	0	1	t	t	Product	8	DRESS	08h3
183	Flared dress  >  long 08i1	t	0	1	t	t	Product	8	DRESS	08i1
184	Flared dress  >  mini 08i3	t	0	1	t	t	Product	8	DRESS	08i3
185	Loose dress  >  long 08j1	t	0	1	t	t	Product	8	DRESS	08j1
186	Pleated dress  >  long 08k1	t	0	1	t	t	Product	8	DRESS	08k1
187	Slit dress > long 08l1	t	0	1	t	t	Product	8	DRESS	08l1
188	Sleeveless dress > long 08m1	t	0	1	t	t	Product	8	DRESS	08m1
189	Sleeveless dress > midi 08m2	t	0	1	t	t	Product	8	DRESS	08m2
190	Sleeveless dress > mini 08m3	t	0	1	t	t	Product	8	DRESS	08m3
191	Fine straps dress > long 08n1	t	0	1	t	t	Product	8	DRESS	08n1
192	Fine straps dress > midi 08n2	t	0	1	t	t	Product	8	DRESS	08n2
193	Fine straps dress > mini 08n3	t	0	1	t	t	Product	8	DRESS	08n3
194	Off the shoulder dress > midi 08o2	t	0	1	t	t	Product	8	DRESS	08o2
195	Off the shoulder dress > mini 08o3	t	0	1	t	t	Product	8	DRESS	08o3
196	Single sleeve dress > long 08p1	t	0	1	t	t	Product	8	DRESS	08p1
197	Single sleeve dress > midi 08p2	t	0	1	t	t	Product	8	DRESS	08p2
198	Single sleeve dress > mini 08p3	t	0	1	t	t	Product	8	DRESS	08p3
199	Large sleeves dress > midi 08q2	t	0	1	t	t	Product	8	DRESS	08q2
200	Large sleeves dress > mini 08q3	t	0	1	t	t	Product	8	DRESS	08q3
201	Long sleeves dress > long 08r1	t	0	1	t	t	Product	8	DRESS	08r1
202	Long sleeves dress > midi 08r2	t	0	1	t	t	Product	8	DRESS	08r2
203	Long sleeves dress > mini 08r3	t	0	1	t	t	Product	8	DRESS	08r3
204	Knitted dress > long 08s1	t	0	1	t	t	Product	8	DRESS	08s1
205	Sheer dress > long 08t1	t	0	1	t	t	Product	8	DRESS	08t1
206	Sheer dress > mini 08t3	t	0	1	t	t	Product	8	DRESS	08t3
207	Lace dress all 08u	t	0	1	t	t	Product	8	DRESS	08u
208	Mesh dress all 08v	t	0	1	t	t	Product	8	DRESS	08v
209	Tweed dress 08v11	t	0	1	t	t	Product	8	DRESS	08v11
210	Velvet dress 08v12	t	0	1	t	t	Product	8	DRESS	08v12
211	Denim dress 08w	t	0	1	t	t	Product	8	DRESS	08w
212	Leather dress > midi 08x2	t	0	1	t	t	Product	8	DRESS	08x2
213	Prints&patterns dress 08y1	t	0	1	t	t	Product	8	DRESS	08y1
214	Checks&stripes dress 08y2	t	0	1	t	t	Product	8	DRESS	08y2
215	Coverall 09a	t	0	1	t	t	Product	9	JUMPSUIT all in one	09a
216	Jumpsuit 09b	t	0	1	t	t	Product	9	JUMPSUIT all in one	09b
217	Rompers 09c	t	0	1	t	t	Product	9	JUMPSUIT all in one	09c
218	Off the shoulder jumpsuit 09d	t	0	1	t	t	Product	9	JUMPSUIT all in one	09d
219	Leather jumpsuit 09d1	t	0	1	t	t	Product	9	JUMPSUIT all in one	09d1
220	Prints&patterns jumpsuit 09f	t	0	1	t	t	Product	9	JUMPSUIT all in one	09f
221	Trousers&jacket > fitted 10a	t	0	1	t	t	Product	10	SUITS trousers jacket 	10a
222	Trousers&jacket > loose 10b	t	0	1	t	t	Product	10	SUITS trousers jacket 	10b
223	Trousers&jacket > oversized 10c	t	0	1	t	t	Product	10	SUITS trousers jacket 	10c
224	Trousers&jacket > sleeveless 10d	t	0	1	t	t	Product	10	SUITS trousers jacket 	10d
225	Trousers&jacket > cropped 10d1	t	0	1	t	t	Product	10	SUITS trousers jacket 	10d1
226	Tuxedo 10d2	t	0	1	t	t	Product	10	SUITS trousers jacket 	10d2
227	Trousers&blouson 10f	t	0	1	t	t	Product	10	SUITS trousers jacket 	10f
228	Occasion suit 10f1	t	0	1	t	t	Product	10	SUITS trousers jacket 	10f1
229	Two pieces suit 10f2	t	0	1	t	t	Product	10	SUITS trousers jacket 	10f2
230	Three pieces suit 10f3	t	0	1	t	t	Product	10	SUITS trousers jacket 	10f3
231	Waistcoat suit 10f4	t	0	1	t	t	Product	10	SUITS trousers jacket 	10f4
232	Pajama suit 10f5	t	0	1	t	t	Product	10	SUITS trousers jacket 	10f5
233	Sailor suit 10f6	t	0	1	t	t	Product	10	SUITS trousers jacket 	10f6
234	Tweed suit 10f7	t	0	1	t	t	Product	10	SUITS trousers jacket 	10f7
235	Denim suit 10f10	t	0	1	t	t	Product	10	SUITS trousers jacket 	10f10
236	Velvet suit 10f11	t	0	1	t	t	Product	10	SUITS trousers jacket 	10f11
237	Short suit 10g	t	0	1	t	t	Product	10	SUITS short	10g
238	Skirt suit > long 10h1	t	0	1	t	t	Product	10	SUITS skirt	10h1
239	Skirt suit > midi 10h2	t	0	1	t	t	Product	10	SUITS skirt	10h2
240	Skirt suit > mini 10h3	t	0	1	t	t	Product	10	SUITS skirt	10h3
241	Separates trousers&jacket 10i1	t	0	1	t	t	Product	10	SUITS separates	10i1
242	Separates trousers&top 10i2	t	0	1	t	t	Product	10	SUITS separates	10i2
243	Separates short&jacket 10j1	t	0	1	t	t	Product	10	SUITS separates	10j1
244	Separates short&top 10j2	t	0	1	t	t	Product	10	SUITS separates	10j2
245	Separates skirt&jacket 10k1	t	0	1	t	t	Product	10	SUITS separates	10k1
246	Separates skirt&top 10k2	t	0	1	t	t	Product	10	SUITS separates	10k2
247	Outfit separates 10k3	t	0	1	t	t	Product	10	SUITS separates	10k3
248	Separates prints&patterns 10l	t	0	1	t	t	Product	10	SUITS separates	10l
249	Separates checks 10l1	t	0	1	t	t	Product	10	SUITS separates	10l1
250	Separates stripes 10l2	t	0	1	t	t	Product	10	SUITS separates	10l2
251	Tailored jacket > long length 11a1	t	0	1	t	t	Product	11	JACKET tailored jacket 	11a1
252	Tailored jacket > regular length 11a2	t	0	1	t	t	Product	11	JACKET tailored jacket 	11a2
253	Tailored jacket > hip length 11a3	t	0	1	t	t	Product	11	JACKET tailored jacket 	11a3
254	Cropped tailored jacket 11a4	t	0	1	t	t	Product	11	JACKET tailored jacket 	11a4
255	Double breasted tailored jacket 11b	t	0	1	t	t	Product	11	JACKET tailored jacket 	11b
256	Oversized tailored jacket 11c	t	0	1	t	t	Product	11	JACKET tailored jacket 	11c
257	Sleeveless tailored jacket 11d1	t	0	1	t	t	Product	11	JACKET tailored jacket 	11d1
258	Short sleeves tailored jacket 11d2	t	0	1	t	t	Product	11	JACKET tailored jacket 	11d2
259	Asymmetric jacket 11d3	t	0	1	t	t	Product	11	JACKET tailored jacket 	11d3
260	Collarless jacket 11f	t	0	1	t	t	Product	11	JACKET tailored jacket 	11f
261	Cropped jacket 11g	t	0	1	t	t	Product	11	JACKET tailored jacket 	11g
262	Front flap pockets jacket 11h	t	0	1	t	t	Product	11	JACKET tailored jacket 	11h
263	Military tailored jacket 11h2	t	0	1	t	t	Product	11	JACKET tailored jacket 	11h2
264	Occasion jacket 11h3	t	0	1	t	t	Product	11	JACKET tailored jacket 	11h3
265	Wrap jacket 11h4	t	0	1	t	t	Product	11	JACKET tailored jacket 	11h4
266	Belted jacket 11h5	t	0	1	t	t	Product	11	JACKET tailored jacket 	11h5
267	Peplum jacket 11h6	t	0	1	t	t	Product	11	JACKET tailored jacket 	11h6
268	Hoodies jacket 11i	t	0	1	t	t	Product	11	JACKET tailored jacket 	11i
269	Sleeveless jacket 11j1	t	0	1	t	t	Product	11	JACKET tailored jacket 	11j1
270	Large sleeves jacket 11j2	t	0	1	t	t	Product	11	JACKET tailored jacket 	11j2
271	Slit sleeves jacket 11j3	t	0	1	t	t	Product	11	JACKET tailored jacket 	11j3
272	Large shoulders jacket 11k	t	0	1	t	t	Product	11	JACKET tailored jacket 	11k
273	Tweed jacket 11l1	t	0	1	t	t	Product	11	JACKET tailored jacket 	11l1
274	Leather jacket 11l2	t	0	1	t	t	Product	11	JACKET tailored jacket 	11l2
275	Leather tailored jacket 11l3	t	0	1	t	t	Product	11	JACKET tailored jacket 	11l3
276	Velvet jacket 11l6	t	0	1	t	t	Product	11	JACKET tailored jacket 	11l6
277	Woollen jacket 11l7	t	0	1	t	t	Product	11	JACKET tailored jacket 	11l7
278	Prints&patterns jacket 11m	t	0	1	t	t	Product	11	JACKET tailored jacket 	11m
279	Denim jacket 11n	t	0	1	t	t	Product	11	JACKET denim jacket 	11n
280	Fitted denim jacket 11n1	t	0	1	t	t	Product	11	JACKET denim jacket 	11n1
281	Oversized denim jacket 11n2	t	0	1	t	t	Product	11	JACKET denim jacket 	11n2
282	Patchwork denim jacket 11n3	t	0	1	t	t	Product	11	JACKET denim jacket 	11n3
283	Sleeveless denim jacket 11n4	t	0	1	t	t	Product	11	JACKET denim jacket 	11n4
284	Bleached denim jacket 11n5	t	0	1	t	t	Product	11	JACKET denim jacket 	11n5
285	Colored denim jacket 11n6	t	0	1	t	t	Product	11	JACKET denim jacket 	11n6
286	Parka hoodies 11o	t	0	1	t	t	Product	11	JACKET casual blouson	11o
287	Fleece 11o1	t	0	1	t	t	Product	11	JACKET casual blouson	11o1
288	Hoodies 11o2	t	0	1	t	t	Product	11	JACKET casual blouson	11o2
289	Track jacket 11o3	t	0	1	t	t	Product	11	JACKET casual blouson	11o3
290	Side zip jacket 11o4	t	0	1	t	t	Product	11	JACKET casual blouson	11o4
291	Down jacket 11o5	t	0	1	t	t	Product	11	JACKET casual blouson	11o5
292	Biker jacket 11p	t	0	1	t	t	Product	11	JACKET casual blouson	11p
293	Leather biker jacket 11pa	t	0	1	t	t	Product	11	JACKET casual blouson	11pa
294	Bombers 11p1	t	0	1	t	t	Product	11	JACKET casual blouson	11p1
295	Baseball jacket 11p2	t	0	1	t	t	Product	11	JACKET casual blouson	11p2
296	Workwear 11p3	t	0	1	t	t	Product	11	JACKET casual blouson	11p3
297	Army jacket 11p4  	t	0	1	t	t	Product	11	JACKET casual blouson	11p4
298	Blouson > long 11q1	t	0	1	t	t	Product	11	JACKET casual blouson	11q1
299	Blouson > medium 11q2	t	0	1	t	t	Product	11	JACKET casual blouson	11q2
300	Cropped blouson 11q3	t	0	1	t	t	Product	11	JACKET casual blouson	11q3
301	Oversized blouson 11r	t	0	1	t	t	Product	11	JACKET casual blouson	11r
302	Sleeveless blouson 11s1	t	0	1	t	t	Product	11	JACKET casual blouson	11s1
303	Short sleeves blouson 11s2	t	0	1	t	t	Product	11	JACKET casual blouson	11s2
304	Windproof blouson 11u1	t	0	1	t	t	Product	11	JACKET casual blouson	11u1
305	Leather blouson jacket 11u2	t	0	1	t	t	Product	11	JACKET casual blouson	11u2
306	Faux fur blouson jacket 11u3	t	0	1	t	t	Product	11	JACKET casual blouson	11u3
307	Prints&patterns blouson 11v	t	0	1	t	t	Product	11	JACKET casual blouson	11v
308	Trench coat > long length 12a1	t	0	1	t	t	Product	12	COAT trench coat 	12a1
309	Trench coat > knee length 12a2	t	0	1	t	t	Product	12	COAT trench coat 	12a2
310	Trench coat > short length 12a3	t	0	1	t	t	Product	12	COAT trench coat 	12a3
311	Short sleeves trench coat 12b	t	0	1	t	t	Product	12	COAT trench coat 	12b
312	Trench dress 12b1	t	0	1	t	t	Product	12	COAT trench coat 	12b1
313	Trench coat deep yoke 12b2	t	0	1	t	t	Product	12	COAT trench coat 	12b2
314	Checks&stripes trench coat 12k	t	0	1	t	t	Product	12	COAT trench coat 	12k
315	Parka hoodie 12c	t	0	1	t	t	Product	12	COAT	12c
316	Down jacket 12c1	t	0	1	t	t	Product	12	COAT	12c1
317	Wind coat raincoat 12d	t	0	1	t	t	Product	12	COAT	12d
318	Egg shape coat 12d1	t	0	1	t	t	Product	12	COAT	12d1
319	Straight shape coat 12f	t	0	1	t	t	Product	12	COAT	12f
320	Double breasted coat 12f1	t	0	1	t	t	Product	12	COAT	12f1
321	Pea coat 12f2	t	0	1	t	t	Product	12	COAT	12f2
322	Duffle coat 12f3	t	0	1	t	t	Product	12	COAT	12f3
323	Occasion coat 12f4	t	0	1	t	t	Product	12	COAT	12f4
324	Military coat 12f5	t	0	1	t	t	Product	12	COAT	12f5
325	Wrap coat 12f6	t	0	1	t	t	Product	12	COAT	12f6
326	Cape 12f7	t	0	1	t	t	Product	12	COAT	12f7
327	Flared coat 12f8	t	0	1	t	t	Product	12	COAT	12f8
328	Statement coat 12f9	t	0	1	t	t	Product	12	COAT	12f9
329	A line coat 12f10	t	0	1	t	t	Product	12	COAT	12f10
330	Coat > long length 12g1	t	0	1	t	t	Product	12	COAT	12g1
331	Coat > knee length 12g2	t	0	1	t	t	Product	12	COAT	12g2
332	Coat > short length 12g3	t	0	1	t	t	Product	12	COAT	12g3
333	Sleeveless coat 12h	t	0	1	t	t	Product	12	COAT	12h
334	Raglan sleeves coat 12h1	t	0	1	t	t	Product	12	COAT	12h1
335	Tweed coat 12i1	t	0	1	t	t	Product	12	COAT	12i1
336	Leather coat 12i2	t	0	1	t	t	Product	12	COAT	12i2
337	Faux fur coat 12i3	t	0	1	t	t	Product	12	COAT	12i3
338	Prints&patterns coat 12j	t	0	1	t	t	Product	12	COAT	12j
339	Pareo 13a	t	0	1	t	t	Product	13	SPORT|ACTIVE|BEACH	13a
340	Single sleeve swimsuit 13b	t	0	1	t	t	Product	13	SPORT|ACTIVE|BEACH	13b
341	Bikini 13b1	t	0	1	t	t	Product	13	SPORT|ACTIVE|BEACH	13b1
342	Sun dress 13c	t	0	1	t	t	Product	13	SPORT|ACTIVE|BEACH	13c
343	Bodysuit > long 13d	t	0	1	t	t	Product	13	SPORT|ACTIVE|BEACH	13d
344	Bodysuit > short 13d1	t	0	1	t	t	Product	13	SPORT|ACTIVE|BEACH	13d1
345	Leggings&bra 13f	t	0	1	t	t	Product	13	SPORT|ACTIVE|BEACH	13f
346	Track pants&hoodie 13g	t	0	1	t	t	Product	13	SPORT|ACTIVE|BEACH	13g
347	Track pants 13g1	t	0	1	t	t	Product	13	SPORT|ACTIVE|BEACH	13g1
348	Track pants&jacket 13g2	t	0	1	t	t	Product	13	SPORT|ACTIVE|BEACH	13g2
349	Skort 13g3	t	0	1	t	t	Product	13	SPORT|ACTIVE|BEACH	13g3
350	Gradients 60a	t	0	1	t	t	Fabric	60	CHIFFON&SHEER FABRICS	60a
351	Layering 60b	t	0	1	t	t	Fabric	60	CHIFFON&SHEER FABRICS	60b
352	Plain 60c	t	0	1	t	t	Fabric	60	CHIFFON&SHEER FABRICS	60c
353	Stiff 60d	t	0	1	t	t	Fabric	60	CHIFFON&SHEER FABRICS	60d
354	Bleached 61a	t	0	1	t	t	Fabric	61	DENIM	61a
355	Stone washed 61b	t	0	1	t	t	Fabric	61	DENIM	61b
356	Medium blue 61c	t	0	1	t	t	Fabric	61	DENIM	61c
357	Indigo 61d	t	0	1	t	t	Fabric	61	DENIM	61d
358	Colored 61d1	t	0	1	t	t	Fabric	61	DENIM	61d1
359	Tie dyed denim 61f	t	0	1	t	t	Fabric	61	DENIM	61f
360	Distressed 61g	t	0	1	t	t	Fabric	61	DENIM	61g
361	Recomposed denim 61h	t	0	1	t	t	Fabric	61	DENIM	61h
362	Denim stretch 61i	t	0	1	t	t	Fabric	61	DENIM	61i
363	3D effect 62a	t	0	1	t	t	Fabric	62	FANCY FABRIC	62a
364	Brocade 62b	t	0	1	t	t	Fabric	62	FANCY FABRIC	62b
365	Pleated 62c	t	0	1	t	t	Fabric	62	FANCY FABRIC	62c
366	Shiny 62d	t	0	1	t	t	Fabric	62	FANCY FABRIC	62d
367	Silver 62d1	t	0	1	t	t	Fabric	62	FANCY FABRIC	62d1
368	Textured 62f	t	0	1	t	t	Fabric	62	FANCY FABRIC	62f
369	Gold lame 62g	t	0	1	t	t	Fabric	62	FANCY FABRIC	62g
370	Ruffles 62h	t	0	1	t	t	Fabric	62	FANCY FABRIC	62h
371	Fringes 62i 	t	0	1	t	t	Fabric	62	FANCY FABRIC	62i
372	Fluid 63a	t	0	1	t	t	Fabric	63	KNIT	63a
373	Fine gauge 63b	t	0	1	t	t	Fabric	63	KNIT	63b
374	Big gauge 63c	t	0	1	t	t	Fabric	63	KNIT	63c
375	Ribbing 63d	t	0	1	t	t	Fabric	63	KNIT	63d
376	Cable stitch 63d1	t	0	1	t	t	Fabric	63	KNIT	63d1
377	Jersey French terry 63f	t	0	1	t	t	Fabric	63	KNIT	63f
378	Melange yarns 63g	t	0	1	t	t	Fabric	63	KNIT	63g
379	Destressed knit 63h	t	0	1	t	t	Fabric	63	KNIT	63h
380	Fancy knit 63i	t	0	1	t	t	Fabric	63	KNIT	63i
381	Hairy knit 63j	t	0	1	t	t	Fabric	63	KNIT	63j
382	Mesh 63k	t	0	1	t	t	Fabric	63	KNIT	63k
383	Color block knit 63l	t	0	1	t	t	Fabric	63	KNIT	63l
384	Stripes knit 63m	t	0	1	t	t	Fabric	63	KNIT	63m
385	Geometric patterns knit 63n	t	0	1	t	t	Fabric	63	KNIT	63n
386	Shiny knit 63o	t	0	1	t	t	Fabric	63	KNIT	63o
387	Metallic knit 63p	t	0	1	t	t	Fabric	63	KNIT	63p
388	Woollen knit 63r	t	0	1	t	t	Fabric	63	KNIT	63r
389	natural knit 63s	t	0	1	t	t	Fabric	63	KNIT	63s
390	Synthetic knit 63t	t	0	1	t	t	Fabric	63	KNIT	63t
391	Lace 64a	t	0	1	t	t	Fabric	64	LACES&NET	64a
392	Colored lace 64b	t	0	1	t	t	Fabric	64	LACES&NET	64b
393	Embroidery 64c	t	0	1	t	t	Fabric	64	LACES&NET	64c
394	Openwork 64d	t	0	1	t	t	Fabric	64	LACES&NET	64d
395	Ruffles&fringes 64d1	t	0	1	t	t	Fabric	64	LACES&NET	64d1
396	Crochet 64f	t	0	1	t	t	Fabric	64	LACES&NET	64f
397	Mesh 64g	t	0	1	t	t	Fabric	64	LACES&NET	64g
398	Skin touch 65a	t	0	1	t	t	Fabric	65	LEATHER|PU	65a
399	Suede 65b	t	0	1	t	t	Fabric	65	LEATHER|PU	65b
400	Stiff 65c	t	0	1	t	t	Fabric	65	LEATHER|PU	65c
401	Shiny 65d	t	0	1	t	t	Fabric	65	LEATHER|PU	65d
402	Studs&decorations 65d1	t	0	1	t	t	Fabric	65	LEATHER|PU	65d1
403	Colored 65f	t	0	1	t	t	Fabric	65	LEATHER|PU	65f
404	Mesh 65g	t	0	1	t	t	Fabric	65	LEATHER|PU	65g
405	Patchwork 65h	t	0	1	t	t	Fabric	65	LEATHER|PU	65h
406	Snake skins 65i	t	0	1	t	t	Fabric	65	LEATHER|PU	65i
407	Pu faux leather 65j	t	0	1	t	t	Fabric	65	LEATHER|PU	65j
408	Skins 65k	t	0	1	t	t	Fabric	65	LEATHER|PU	65k
409	Washed leather 65l	t	0	1	t	t	Fabric	65	LEATHER|PU	65l
410	Stretch leather 65m	t	0	1	t	t	Fabric	65	LEATHER|PU	65m
411	Fluid 66a	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66a
412	Satin silky 66b	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66b
413	Suiting fabrics 66c	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66c
414	Canvas 66d	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66d
415	Chino 66d1	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66d1
416	Gabardine 66f	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66f
417	Stiff 66g	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66g
418	Textured 66h	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66h
419	Lightweight fabrics 66i	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66i
420	Woollen fabrics 66j	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66j
421	Natural fabrics 66l	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66l
422	Cotton 66m	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66m
423	Linen 66n	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66n
424	Weaves 66r	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66r
425	Stretch fabrics 66s	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66s
426	All fabrics stripes 66t	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66t
427	All fabrics checks 66u	t	0	1	t	t	Fabric	66	PLAIN FABRICS	66u
428	Plain 67a	t	0	1	t	t	Fabric	67	SHIRTING FABRICS	67a
429	Stripes 67b	t	0	1	t	t	Fabric	67	SHIRTING FABRICS	67b
430	Checks 67c	t	0	1	t	t	Fabric	67	SHIRTING FABRICS	67c
431	Patchwork 67d	t	0	1	t	t	Fabric	67	SHIRTING FABRICS	67d
432	Chambray 67d1	t	0	1	t	t	Fabric	67	SHIRTING FABRICS	67d1
433	Dobby 67f	t	0	1	t	t	Fabric	67	SHIRTING FABRICS	67f
434	Weaves 67g	t	0	1	t	t	Fabric	67	SHIRTING FABRICS	67g
435	Shirting fabrics 67h	t	0	1	t	t	Fabric	67	SHIRTING FABRICS	67h
436	Stretch fabrics 68a	t	0	1	t	t	Fabric	68	STRETCH FABRICS	68a
437	Light nylon 69a	t	0	1	t	t	Fabric	69	TECHNICAL FABRICS	69a
438	Waterproof windproof 69b	t	0	1	t	t	Fabric	69	TECHNICAL FABRICS	69b
439	Bonded 69c	t	0	1	t	t	Fabric	69	TECHNICAL FABRICS	69c
440	Quilted 69d	t	0	1	t	t	Fabric	69	TECHNICAL FABRICS	69d
441	Functional 69d1	t	0	1	t	t	Fabric	69	TECHNICAL FABRICS	69d1
442	Finishing 69f	t	0	1	t	t	Fabric	69	TECHNICAL FABRICS	69f
443	PVC 69g	t	0	1	t	t	Fabric	69	TECHNICAL FABRICS	69g
444	Summer tweed 70a	t	0	1	t	t	Fabric	70	TWEED	70a
445	Fancy tweed 70b	t	0	1	t	t	Fabric	70	TWEED	70b
446	Velvet pane 71a	t	0	1	t	t	Fabric	71	VELVET	71a
447	Corduroy 71b	t	0	1	t	t	Fabric	71	VELVET	71b
448	Colored velvet 71c	t	0	1	t	t	Fabric	71	VELVET	71c
449	Velvet 71d	t	0	1	t	t	Fabric	71	VELVET	71d
450	Short hairs 72a	t	0	1	t	t	Fabric	72	FUR FAKE FUR 	72a
451	Long hairs 72b	t	0	1	t	t	Fabric	72	FUR FAKE FUR	72b
452	Fabric touch 73a	t	0	1	t	t	Fabric	73	TOUCH	73a
453	Fabric wash 74a	t	0	1	t	t	Fabric	74	WASH	74a
454	Animals skin 81a	t	0	1	t	t	Print	81	ANIMALS	81a
455	Pets 81b	t	0	1	t	t	Print	81	ANIMALS	81b
456	Insects birds 81c	t	0	1	t	t	Print	81	ANIMALS	81c
457	Fish seashell 81d	t	0	1	t	t	Print	81	ANIMALS	81d
458	Abstract 82a	t	0	1	t	t	Print	82	ARTY 	82a
459	B&W patterns 82b	t	0	1	t	t	Print	82	ARTY 	82b
460	Realistic art 82c	t	0	1	t	t	Print	82	ARTY 	82c
461	Shades&gradients 82d	t	0	1	t	t	Print	82	ARTY 	82d
462	Textures 82d1	t	0	1	t	t	Print	82	ARTY 	82d1
463	Water painting 82f	t	0	1	t	t	Print	82	ARTY 	82f
464	Graffiti 82g	t	0	1	t	t	Print	82	ARTY 	82g
465	Arty camouflage 82h	t	0	1	t	t	Print	82	ARTY 	82h
466	Digital patterns 82i	t	0	1	t	t	Print	82	ARTY 	82i
467	Photo print 82j	t	0	1	t	t	Print	82	ARTY 	82j
468	Sketches 82k	t	0	1	t	t	Print	82	ARTY 	82k
469	Cartoon 82l	t	0	1	t	t	Print	82	ARTY 	82l
470	Arabesque 83a	t	0	1	t	t	Print	83	DECORATIVE	83a
471	Mosaic 83b	t	0	1	t	t	Print	83	DECORATIVE	83b
472	Decorative placed ornament 83c	t	0	1	t	t	Print	83	DECORATIVE	83c
473	Ethnic geometric graphic 84a	t	0	1	t	t	Print	84	ETHNIC	84a
474	Tie dye 84b	t	0	1	t	t	Print	84	ETHNIC	84b
475	Camouflage flowers 85a	t	0	1	t	t	Print	85	FLOWERS	85a
476	Dark background flowers 85b	t	0	1	t	t	Print	85	FLOWERS	85b
477	Paisley 85c	t	0	1	t	t	Print	85	FLOWERS	85c
478	Flowers patterns combinations 85d	t	0	1	t	t	Print	85	FLOWERS	85d
479	Romantic flowers 85d1	t	0	1	t	t	Print	85	FLOWERS	85d1
480	Big&bold flowers 85f	t	0	1	t	t	Print	85	FLOWERS	85f
481	Medium flowers 85g	t	0	1	t	t	Print	85	FLOWERS	85g
482	All types flowers 85h	t	0	1	t	t	Print	85	FLOWERS	85h
483	Leaves 85i	t	0	1	t	t	Print	85	FLOWERS	85i
484	Strawberry 86a	t	0	1	t	t	Print	86	FRUITS	86a
485	Realistic fruits 86b	t	0	1	t	t	Print	86	FRUITS	86b
486	All over geometric 87a	t	0	1	t	t	Print	87	GEOMETRIC	87a
487	Polka dots 87b	t	0	1	t	t	Print	87	GEOMETRIC	87b
488	Stars 87c	t	0	1	t	t	Print	87	GEOMETRIC	87c
489	Wavy lines 87d	t	0	1	t	t	Print	87	GEOMETRIC	87d
490	Color block	t	0	1	t	t	Print	87	GEOMETRIC	87f
491	Front placed patterns 88a	t	0	1	t	t	Print	88	PLACED PATTERNS	88a
492	Placed patterns large repeat 88b	t	0	1	t	t	Print	88	PLACED PATTERNS	88b
493	Logo 89a	t	0	1	t	t	Print	89	WORDING	89a
494	Typography 89b	t	0	1	t	t	Print	89	WORDING	89b
495	Slogan 89c	t	0	1	t	t	Print	89	WORDING	89c
496	Stamp 89d	t	0	1	t	t	Print	89	WORDING	89d
497	Diamond checks 90a  	t	0	1	t	t	Print	90	CHECKS	90a
498	Gingham 90b	t	0	1	t	t	Print	90	CHECKS	90b
499	Houndstooth 90c	t	0	1	t	t	Print	90	CHECKS	90c
500	Madras checks 90d	t	0	1	t	t	Print	90	CHECKS	90d
501	Pin checks 90d1	t	0	1	t	t	Print	90	CHECKS	90d1
502	Prince of wales 90f	t	0	1	t	t	Print	90	CHECKS	90f
503	Tartan plaid 90g	t	0	1	t	t	Print	90	CHECKS	90g
504	Shirting checks 90h 	t	0	1	t	t	Print	90	CHECKS	90h
505	Navy stripes 91a	t	0	1	t	t	Print	91	STRIPES	91a
506	Shirting stripes 91b	t	0	1	t	t	Print	91	STRIPES	91b
507	Sporty stripes 91c	t	0	1	t	t	Print	91	STRIPES	91c
508	Vertical stripes 91d	t	0	1	t	t	Print	91	STRIPES	91d
509	Diagonal stripes 91f	t	0	1	t	t	Print	91	STRIPES	91f
510	Multiple stripes 91f1	t	0	1	t	t	Print	91	STRIPES	91f1
511	Weaves 92a	t	0	1	t	t	Print	92	WEAVES 	92a
512	Pure white 30a	t	0	1	t	t	Color	30	WHITE	30a
513	Off white 30b	t	0	1	t	t	Color	30	WHITE	30b
514	W&B > details 30c	t	0	1	t	t	Color	30	WHITE	30c
515	W&B > top bottom 30d	t	0	1	t	t	Color	30	WHITE	30d
516	White&beige 30d1	t	0	1	t	t	Color	30	WHITE	30d1
517	White&blue 30f	t	0	1	t	t	Color	30	WHITE	30f
518	White&yellow 30g	t	0	1	t	t	Color	30	WHITE	30g
519	White&red 30h	t	0	1	t	t	Color	30	WHITE	30h
520	Ivory 31a	t	0	1	t	t	Color	31	BEIGE	31a
521	Linen 31b	t	0	1	t	t	Color	31	BEIGE	31b
522	Champagne 31c	t	0	1	t	t	Color	31	BEIGE	31c
523	Almond 31d	t	0	1	t	t	Color	31	BEIGE	31d
524	Sand 31d1	t	0	1	t	t	Color	31	BEIGE	31d1
525	Wholegrain 31f	t	0	1	t	t	Color	31	BEIGE	31f
526	Ecru 31g	t	0	1	t	t	Color	31	BEIGE	31g
527	Rosewood 31h	t	0	1	t	t	Color	31	BEIGE	31h
528	Taupe 31i	t	0	1	t	t	Color	31	BEIGE	31i
529	Wheat shades 31j	t	0	1	t	t	Color	31	BEIGE	31j
530	Vanilla 32a	t	0	1	t	t	Color	32	YELLOW	32a
531	Eggshell 32b	t	0	1	t	t	Color	32	YELLOW	32b
532	Citrine 32c	t	0	1	t	t	Color	32	YELLOW	32c
533	Sunflower 32d	t	0	1	t	t	Color	32	YELLOW	32d
534	Lemon 32d1	t	0	1	t	t	Color	32	YELLOW	32d1
535	Acid yellow 32f	t	0	1	t	t	Color	32	YELLOW	32f
536	Amber 32g	t	0	1	t	t	Color	32	YELLOW	32g
537	Corn 32h	t	0	1	t	t	Color	32	YELLOW	32h
538	Mustard 32i	t	0	1	t	t	Color	32	YELLOW	32i
539	Peach 33a	t	0	1	t	t	Color	33	ORANGE	33a
540	Coral 33b	t	0	1	t	t	Color	33	ORANGE	33b
541	Carrot 33c	t	0	1	t	t	Color	33	ORANGE	33c
542	Flame 33d	t	0	1	t	t	Color	33	ORANGE	33d
543	Crimson 33d1	t	0	1	t	t	Color	33	ORANGE	33d1
544	Neon orange 33f	t	0	1	t	t	Color	33	ORANGE	33f
545	Nude 34a	t	0	1	t	t	Color	34	PINK	34a
546	Misty rose 34b	t	0	1	t	t	Color	34	PINK	34b
547	Delicate pink 34c	t	0	1	t	t	Color	34	PINK	34c
548	Baby pink 34d	t	0	1	t	t	Color	34	PINK	34d
549	Tea rose 34d1	t	0	1	t	t	Color	34	PINK	34d1
550	Wisteria 34f	t	0	1	t	t	Color	34	PINK	34f
551	Candy pink 34g	t	0	1	t	t	Color	34	PINK	34g
552	Fuchsia 34h	t	0	1	t	t	Color	34	PINK	34h
553	Neon pink 34i 	t	0	1	t	t	Color	34	PINK	34i
554	Lilac 35a	t	0	1	t	t	Color	35	PURPLE	35a
555	Amethyst 35b	t	0	1	t	t	Color	35	PURPLE	35b
556	Royal purple 35c	t	0	1	t	t	Color	35	PURPLE	35c
557	Eggplant 35d	t	0	1	t	t	Color	35	PURPLE	35d
558	Strawberry 36a	t	0	1	t	t	Color	36	RED	36a
559	Vermillion 36b	t	0	1	t	t	Color	36	RED	36b
560	Cherry 36c	t	0	1	t	t	Color	36	RED	36c
561	Burgundy 36d	t	0	1	t	t	Color	36	RED	36d
562	Red&white 36d1	t	0	1	t	t	Color	36	RED	36d1
563	Red&black 36f	t	0	1	t	t	Color	36	RED	36f
564	Earth red 36g	t	0	1	t	t	Color	36	RED	36g
565	Copper 37a	t	0	1	t	t	Color	37	BROWN	37a
566	Wenge 37b	t	0	1	t	t	Color	37	BROWN	37b
567	Camel 37c	t	0	1	t	t	Color	37	BROWN	37c
568	Caramel 37d	t	0	1	t	t	Color	37	BROWN	37d
569	Cinnamon 37d1	t	0	1	t	t	Color	37	BROWN	37d1
570	Gingerbread 37f	t	0	1	t	t	Color	37	BROWN	37f
571	Sienna 37g	t	0	1	t	t	Color	37	BROWN	37g
572	Coffee 37h	t	0	1	t	t	Color	37	BROWN	37h
573	Chocolate 37i	t	0	1	t	t	Color	37	BROWN	37i
574	Pink gold 38a	t	0	1	t	t	Color	38	GOLD	38a
575	Green gold 38b	t	0	1	t	t	Color	38	GOLD	38b
576	Pure gold 38c	t	0	1	t	t	Color	38	GOLD	38c
577	Silver gold 38d	t	0	1	t	t	Color	38	GOLD	38d
578	Olive drab 39a	t	0	1	t	t	Color	39	KHAKI	39a
579	Verdigris 39b	t	0	1	t	t	Color	39	KHAKI	39b
580	Lichen 39c	t	0	1	t	t	Color	39	KHAKI	39c
581	Lion 39d	t	0	1	t	t	Color	39	KHAKI	39d
582	Walnut 39d1	t	0	1	t	t	Color	39	KHAKI	39d1
583	Celadon 40a	t	0	1	t	t	Color	40	GREEN	40a
584	Aqua 40b	t	0	1	t	t	Color	40	GREEN	40b
585	Chartreuse 40c	t	0	1	t	t	Color	40	GREEN	40c
586	Spring green 40d	t	0	1	t	t	Color	40	GREEN	40d
587	Persian green 40d1	t	0	1	t	t	Color	40	GREEN	40d1
588	Forest 40f	t	0	1	t	t	Color	40	GREEN	40f
589	Emerald 40g	t	0	1	t	t	Color	40	GREEN	40g
590	Pistachio 40h	t	0	1	t	t	Color	40	GREEN	40h
591	Crystal 41a	t	0	1	t	t	Color	41	TURQUOISE	41a
592	Iceberg 41b	t	0	1	t	t	Color	41	TURQUOISE	41b
593	Lagoon 41c	t	0	1	t	t	Color	41	TURQUOISE	41c
594	Blue sky 42a 	t	0	1	t	t	Color	42	BLUE	42a
595	Baby blue 42b	t	0	1	t	t	Color	42	BLUE	42b
596	Azure 42c	t	0	1	t	t	Color	42	BLUE	42c
597	Tiffany blue 42d	t	0	1	t	t	Color	42	BLUE	42d
598	Quartz 42d1	t	0	1	t	t	Color	42	BLUE	42d1
599	Lavender 42f	t	0	1	t	t	Color	42	BLUE	42f
600	Duck blue teal 42g	t	0	1	t	t	Color	42	BLUE	42g
601	Royal blue 42h	t	0	1	t	t	Color	42	BLUE	42h
602	Electric blue 42i	t	0	1	t	t	Color	42	BLUE	42i
603	Cobalt 42j	t	0	1	t	t	Color	42	BLUE	42j
604	Navy 42k	t	0	1	t	t	Color	42	BLUE	42k
605	Ink 42l	t	0	1	t	t	Color	42	BLUE	42l
606	Sapphire 42m	t	0	1	t	t	Color	42	BLUE	42m
607	Snow wash 43a	t	0	1	t	t	Color	43	DENIM BLUE 	43a
608	Light wash 43b	t	0	1	t	t	Color	43	DENIM BLUE 	43b
609	Stone wash 43c	t	0	1	t	t	Color	43	DENIM BLUE 	43c
610	Regular blue 43d	t	0	1	t	t	Color	43	DENIM BLUE 	43d
611	Raw indigo 43d1	t	0	1	t	t	Color	43	DENIM BLUE 	43d1
612	Grey tones 43f	t	0	1	t	t	Color	43	DENIM BLUE 	43f
613	Cloud 44a	t	0	1	t	t	Color	44	GREY	44a
614	Storm 44b	t	0	1	t	t	Color	44	GREY	44b
615	Fossil 44c	t	0	1	t	t	Color	44	GREY	44c
616	Charcoal 44d	t	0	1	t	t	Color	44	GREY	44d
617	Pearl 44d1	t	0	1	t	t	Color	44	GREY	44d1
618	White silver 45a	t	0	1	t	t	Color	45	SILVER	45a
619	Pure silver 45b	t	0	1	t	t	Color	45	SILVER	45b
620	Galactic silver 45c	t	0	1	t	t	Color	45	SILVER	45c
621	Old silver 45d	t	0	1	t	t	Color	45	SILVER	45d
622	Roman silver 45d1	t	0	1	t	t	Color	45	SILVER	45d1
623	Pure black 46a	t	0	1	t	t	Color	46	BLACK	46a
624	Pure shiny black 46b	t	0	1	t	t	Color	46	BLACK	46b
625	Ashes 46c	t	0	1	t	t	Color	46	BLACK	46c
626	B&W > tiny details 46d	t	0	1	t	t	Color	46	BLACK	46d
627	B&W > contrast 46d1	t	0	1	t	t	Color	46	BLACK	46d1
628	B&W > top bottom 46f	t	0	1	t	t	Color	46	BLACK	46f
629	B&W > graphic 46g	t	0	1	t	t	Color	46	BLACK	46g
630	B&W > arty 46h	t	0	1	t	t	Color	46	BLACK	46h
631	Black&blue 46i	t	0	1	t	t	Color	46	BLACK	46i
632	Black&red 46j	t	0	1	t	t	Color	46	BLACK	46j
633	Black&yellow 46k	t	0	1	t	t	Color	46	BLACK	46k
634	Black&metallic 46l	t	0	1	t	t	Color	46	BLACK	46l
635	Black&brown 46m	t	0	1	t	t	Color	46	BLACK	46m
636	Beige > ivory 31a47a	t	0	1	t	t	Color	47	LIGHT COLORS	31a47a
637	Beige > linen 31b47b	t	0	1	t	t	Color	47	LIGHT COLORS	31b47b
638	Yellow > vanilla 32a47c	t	0	1	t	t	Color	47	LIGHT COLORS	32a47c
639	Pink > delicate pink 34c47d	t	0	1	t	t	Color	47	LIGHT COLORS	34c47d
640	Pink > baby pink 34d47d1	t	0	1	t	t	Color	47	LIGHT COLORS	34d47d1
641	Purple > lilac 35a47f	t	0	1	t	t	Color	47	LIGHT COLORS	35a47f
642	Green > celadon 40a47g	t	0	1	t	t	Color	47	LIGHT COLORS	40a47g
643	Turquoise > crystal 41a47h	t	0	1	t	t	Color	47	LIGHT COLORS	41a47h
644	Blue > sky blue 42a47i	t	0	1	t	t	Color	47	LIGHT COLORS	42a47i
645	Denim blue > snow wash 43a47j	t	0	1	t	t	Color	47	LIGHT COLORS	43a47j
646	Grey > pearl 44d147k	t	0	1	t	t	Color	47	LIGHT COLORS	44d147k
647	Beige > champagne 31c48a	t	0	1	t	t	Color	48	PASTEL COLORS 	31c48a
648	Yellow > eggshell 32b48b	t	0	1	t	t	Color	48	PASTEL COLORS 	32b48b
649	Yellow > corn 32h48c	t	0	1	t	t	Color	48	PASTEL COLORS 	32h48c
650	Orange > peach 33a48d	t	0	1	t	t	Color	48	PASTEL COLORS 	33a48d
651	Pink > tea rose 34d148d1	t	0	1	t	t	Color	48	PASTEL COLORS 	34d148d1
652	Green > aqua 40b48f	t	0	1	t	t	Color	48	PASTEL COLORS 	40b48f
653	Blue > baby blue 42b48g	t	0	1	t	t	Color	48	PASTEL COLORS 	42b48g
654	Denim blue > light wash 43b48h	t	0	1	t	t	Color	48	PASTEL COLORS 	43b48h
655	Grey > cloud 44a48i	t	0	1	t	t	Color	48	PASTEL COLORS 	44a48i
656	Silver > white silver 45a49a	t	0	1	t	t	Color	48	PASTEL COLORS 	45a49a
657	Beige > almond 31d49a	t	0	1	t	t	Color	49	NEUTRAL COLORS	31d49a
658	Beige > sand 31d149b	t	0	1	t	t	Color	49	NEUTRAL COLORS	31d149b
659	Beige > wholegrain 31f49c	t	0	1	t	t	Color	49	NEUTRAL COLORS	31f49c
660	Beige > ecru 31g49d	t	0	1	t	t	Color	49	NEUTRAL COLORS	31g49d
661	Beige > rosewood 31h49d1	t	0	1	t	t	Color	49	NEUTRAL COLORS	31h49d1
662	Beige > taupe 31i49f	t	0	1	t	t	Color	49	NEUTRAL COLORS	31i49f
663	Beige > wheat shades 31j49g	t	0	1	t	t	Color	49	NEUTRAL COLORS	31j49g
664	Pink > nude 34a49h	t	0	1	t	t	Color	49	NEUTRAL COLORS	34a49h
665	Pink > misty rose 34b49i	t	0	1	t	t	Color	49	NEUTRAL COLORS	34b49i
666	Khaki > lichen 39c49j	t	0	1	t	t	Color	49	NEUTRAL COLORS	39c49j
667	Blue > quartz 42d149k	t	0	1	t	t	Color	49	NEUTRAL COLORS	42d149k
668	Grey > storm 44b49m	t	0	1	t	t	Color	49	NEUTRAL COLORS	44b49m
669	Green > pistachio 40h49n	t	0	1	t	t	Color	49	NEUTRAL COLORS	40h49n
670	Yellow > citrine 32c50b	t	0	1	t	t	Color	50	MEDIUM COLORS	32c50b
671	Yellow > sunflower 32d50c	t	0	1	t	t	Color	50	MEDIUM COLORS	32d50c
672	Yellow > amber 32g50d	t	0	1	t	t	Color	50	MEDIUM COLORS	32g50d
673	Orange > coral 33b50d1	t	0	1	t	t	Color	50	MEDIUM COLORS	33b50d1
674	Orange > carrot 33c50f	t	0	1	t	t	Color	50	MEDIUM COLORS	33c50f
675	Pink > wisteria 34f50g	t	0	1	t	t	Color	50	MEDIUM COLORS	34f50g
676	Pink > candy pink 34g50h	t	0	1	t	t	Color	50	MEDIUM COLORS	34g50h
677	Red > strawberry 36a50i	t	0	1	t	t	Color	50	MEDIUM COLORS	36a50i
678	Brown > copper 37a50j	t	0	1	t	t	Color	50	MEDIUM COLORS	37a50j
679	Brown > camel 37c50k	t	0	1	t	t	Color	50	MEDIUM COLORS	37c50k
680	Gold > pink gold 38a50l	t	0	1	t	t	Color	50	MEDIUM COLORS	38a50l
681	Khaki > lion 39d50m	t	0	1	t	t	Color	50	MEDIUM COLORS	39d50m
682	Turquoise > iceberg 41b50n	t	0	1	t	t	Color	50	MEDIUM COLORS	41b50n
683	Blue > azure 42c50o	t	0	1	t	t	Color	50	MEDIUM COLORS	42c50o
684	Blue > lavender 42f50p	t	0	1	t	t	Color	50	MEDIUM COLORS	42f50p
685	Blue > royal blue 42h50q	t	0	1	t	t	Color	50	MEDIUM COLORS	42h50q
686	Blue > cobalt 42j50r	t	0	1	t	t	Color	50	MEDIUM COLORS	42j50r
687	Denim blue > stone wash 43c50s	t	0	1	t	t	Color	50	MEDIUM COLORS	43c50s
688	Denim blue > regular blue 43d50t	t	0	1	t	t	Color	50	MEDIUM COLORS	43d50t
689	Grey > fossil 44c50u	t	0	1	t	t	Color	50	MEDIUM COLORS	44c50u
690	Silver > old silver 45d50v	t	0	1	t	t	Color	50	MEDIUM COLORS	45d50v
691	Blue > sapphire 42m50w	t	0	1	t	t	Color	50	MEDIUM COLORS	42m50w
692	Brown > wenge 37b50x	t	0	1	t	t	Color	50	MEDIUM COLORS	37b50x
693	Red > earth 36g50xa	t	0	1	t	t	Color	50	MEDIUM COLORS	36g50xa
694	Yellow > mustard 32i51a	t	0	1	t	t	Color	51	INTENSE COLORS 	32i51a
695	Orange > flame 33d51b	t	0	1	t	t	Color	51	INTENSE COLORS 	33d51b
696	Orange > crimson 33d151c	t	0	1	t	t	Color	51	INTENSE COLORS 	33d151c
697	Pink > fuchsia 34h51d	t	0	1	t	t	Color	51	INTENSE COLORS 	34h51d
698	Purple > royal purple 35c51d1	t	0	1	t	t	Color	51	INTENSE COLORS 	35c51d1
699	Red > vermillion 36b51f	t	0	1	t	t	Color	51	INTENSE COLORS 	36b51f
700	Red > cherry 36c51g	t	0	1	t	t	Color	51	INTENSE COLORS 	36c51g
701	Brown > caramel 37d51h	t	0	1	t	t	Color	51	INTENSE COLORS 	37d51h
702	Brown > cinnamon 37d151i	t	0	1	t	t	Color	51	INTENSE COLORS 	37d151i
703	Brown > gingerbread 37f51j	t	0	1	t	t	Color	51	INTENSE COLORS 	37f51j
704	Brown > sienna 37g51k	t	0	1	t	t	Color	51	INTENSE COLORS 	37g51k
705	Gold > green gold 38b51l	t	0	1	t	t	Color	51	INTENSE COLORS 	38b51l
706	Khaki > olive drab 39a51m	t	0	1	t	t	Color	51	INTENSE COLORS 	39a51m
707	Khaki > walnut 39d151n	t	0	1	t	t	Color	51	INTENSE COLORS 	39d151n
708	Green > forest 40f51o	t	0	1	t	t	Color	51	INTENSE COLORS 	40f51o
709	Blue > electric blue 42i51p	t	0	1	t	t	Color	51	INTENSE COLORS 	42i51p
710	Purple > eggplant 35d52a	t	0	1	t	t	Color	52	DARK COLORS  	35d52a
711	Red > burgundy 36d52b	t	0	1	t	t	Color	52	DARK COLORS  	36d52b
712	Brown > coffee 37h52c	t	0	1	t	t	Color	52	DARK COLORS  	37h52c
713	Khaki > Verdigris 39b52d	t	0	1	t	t	Color	52	DARK COLORS  	39b52d
714	Green > emerald 40g52d1	t	0	1	t	t	Color	52	DARK COLORS  	40g52d1
715	Blue > duck blue 42g52f	t	0	1	t	t	Color	52	DARK COLORS  	42g52f
716	Blue > navy 42k52g	t	0	1	t	t	Color	52	DARK COLORS  	42k52g
717	Blue > ink 42l52h	t	0	1	t	t	Color	52	DARK COLORS  	42l52h
718	Denim blue > raw indigo 43d152i	t	0	1	t	t	Color	52	DARK COLORS  	43d152i
719	Grey > charcoal 44d52j	t	0	1	t	t	Color	52	DARK COLORS  	44d52j
720	Silver > roman silver 45d152k	t	0	1	t	t	Color	52	DARK COLORS  	45d152k
721	Brown > chocolate 37i52l	t	0	1	t	t	Color	52	DARK COLORS  	37i52l
722	Yellow > lemon 32d153a	t	0	1	t	t	Color	53	BOLD COLORS	32d153a
723	Yellow > acid yellow 32f53b	t	0	1	t	t	Color	53	BOLD COLORS	32f53b
724	Purple > amethyst 35b53c	t	0	1	t	t	Color	53	BOLD COLORS	35b53c
725	Gold > pure gold 38c53d	t	0	1	t	t	Color	53	BOLD COLORS	38c53d
726	Green > chartreuse 40c53d1	t	0	1	t	t	Color	53	BOLD COLORS	40c53d1
727	Green > spring green 40d53f	t	0	1	t	t	Color	53	BOLD COLORS	40d53f
728	Green > Persian green 40d153g	t	0	1	t	t	Color	53	BOLD COLORS	40d153g
729	Turquoise > lagoon 41c53h	t	0	1	t	t	Color	53	BOLD COLORS	41c53h
730	Blue > tiffany blue 42d53i	t	0	1	t	t	Color	53	BOLD COLORS	42d53i
731	Silver > galactic silver 45c53j	t	0	1	t	t	Color	53	BOLD COLORS	45c53j
732	Pink > neon pink 34i53k	t	0	1	t	t	Color	53	BOLD COLORS	34i53k
733	Orange > neon orange 33f53l	t	0	1	t	t	Color	53	BOLD COLORS	33f53l
734	Orange contrasts 54b	t	0	1	t	t	Color	54	MULTICO 	54b
735	Light blue harmonies 54c	t	0	1	t	t	Color	54	MULTICO 	54c
736	Light pink harmonies 54d	t	0	1	t	t	Color	54	MULTICO 	54d
737	Yellow harmonies 54d1	t	0	1	t	t	Color	54	MULTICO 	54d1
738	Brown harmonies 54f	t	0	1	t	t	Color	54	MULTICO 	54f
739	Medium harmonies 54g	t	0	1	t	t	Color	54	MULTICO 	54g
740	Dark harmonies 54h	t	0	1	t	t	Color	54	MULTICO 	54h
741	Kaleidoscope 54i	t	0	1	t	t	Color	54	MULTICO 	54i
742	Gradient colors 54j	t	0	1	t	t	Color	54	MULTICO 	54j
743	Gold silver 54k	t	0	1	t	t	Color	54	MULTICO 	54k
744	Bright blocks 55a	t	0	1	t	t	Color	55	COLOR BLOCK	55a
745	Blue blocks 55b	t	0	1	t	t	Color	55	COLOR BLOCK	55b
746	Green blocks 55c	t	0	1	t	t	Color	55	COLOR BLOCK	55c
747	Red blocks 55d	t	0	1	t	t	Color	55	COLOR BLOCK	55d
748	Dark blocks 55d1	t	0	1	t	t	Color	55	COLOR BLOCK	55d1
\.


--
-- Data for Name: annotations_export; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.annotations_export (id, "time", annotation_count, export_text, image_set_id, user_id, format_id, filename) FROM stdin;
4	2020-03-14 22:18:57.616453+08	0	2020Spring: name of the imageset\r\n\r\n: description of the imageset	3	1	1	export_4.txt
5	2020-03-14 22:20:31.169805+08	0	2020Spring: name of the imageset\r\n\r\n: description of the imageset	3	1	1	export_5.txt
\.


--
-- Data for Name: annotations_exportformat; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.annotations_exportformat (id, name, public, base_format, annotation_format, team_id, not_in_image_format, min_verifications, image_aggregation, image_format, name_format, vector_format, last_change_time, include_blurred, include_concealed) FROM stdin;
1	test0	f	%%imageset: name of the imageset\r\n\r\n%%setdescription: description of the imageset	%%minx, %%relminx: minimal x-value of the annotation, absolute or relative value\r\n\r\n%%miny, %%relminy: minimal y-value of the annotation, absolute or relative value	1	%%type: type of the annotation	0	f		export_%%exportid.txt	x%%count1: %%x%%bry%%count1: %%y%%br	2020-03-12 15:00:54.905299+08	t	t
2	test1	f	%%imageset: name of the imageset	%%imagename: name of the image\r\n\r\n%%imagewidth: width of the image\r\n\r\n%%imageheight: height of the image\r\n\r\n%%imageset: name of the imageset\r\n\r\n%%type: annotation type\r\n\r\n%%veriamount: the amount of verifications for the annotation\r\n\r\n%%vector: the annotation vector, as defined in the vector format\r\n\r\n%%cx, %%relcx: x-coordinate of the center of the annotation, absolute or relative value\r\n\r\n%%cy, %%relcy: y-coordinate of the center of the annotation, absolute or relative value\r\n\r\n%%minx, %%relminx: minimal x-value of the annotation, absolute or relative value\r\n\r\n%%miny, %%relminy: minimal y-value of the annotation, absolute or relative value\r\n\r\n%%maxx, %%relmaxx: maximal x-value of the annotation, absolute or relative value\r\n\r\n%%maxy, %%relmaxy: maximal y-value of the annotation, absolute or relative value\r\n\r\n%%rad, %%relrad: radius of the annotation, absolute or relative value\r\n\r\n%%dia, %%reldia: diameter of the annotation, absolute or relative value\r\n\r\n%%width, %%relwidth: width of the annotation, absolute or relative value\r\n\r\n%%height, %%relheight: height of the annotation, absolute or relative value\r\n\r\n%%ifblurred text in between this and %%endif will be displayed if the annotation is marked as blurred\r\n\r\n%%ifnotblurred text in between this and %%endif will be displayed if the annotation is not marked as blurred\r\n\r\n%%ifconcealed text in between this and %%endif will be displayed if the annotation is marked as concealed\r\n\r\n%%ifnotconcealed text in between this and %%endif will be displayed if the annotation is not marked as concealed\r\n\r\n%%endif closes an opened if. This is absolutely necessary for every if.\r\n\r\nNote: nested ifs are not allowed!\r\n\r\n	1	%%type: type of the annotation	0	f		export_%%exportid.txt	x%%count1: %%x%%bry%%count1: %%y%%br	2020-03-12 15:03:46.466389+08	t	t
\.


--
-- Data for Name: annotations_exportformat_annotations_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.annotations_exportformat_annotations_types (id, exportformat_id, annotationtype_id) FROM stdin;
\.


--
-- Data for Name: annotations_verification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.annotations_verification (id, "time", verified, annotation_id, user_id) FROM stdin;
9	2020-03-14 23:08:06.050603+08	t	9	1
10	2020-03-14 23:10:10.524144+08	t	10	1
\.


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group (id, name) FROM stdin;
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add annotation	1	add_annotation
2	Can change annotation	1	change_annotation
3	Can delete annotation	1	delete_annotation
4	Can view annotation	1	view_annotation
5	Can add annotation type	2	add_annotationtype
6	Can change annotation type	2	change_annotationtype
7	Can delete annotation type	2	delete_annotationtype
8	Can view annotation type	2	view_annotationtype
9	Can add export	3	add_export
10	Can change export	3	change_export
11	Can delete export	3	delete_export
12	Can view export	3	view_export
13	Can add verification	4	add_verification
14	Can change verification	4	change_verification
15	Can delete verification	4	delete_verification
16	Can view verification	4	view_verification
17	Can add export format	5	add_exportformat
18	Can change export format	5	change_exportformat
19	Can delete export format	5	delete_exportformat
20	Can view export format	5	view_exportformat
21	Can add image	6	add_image
22	Can change image	6	change_image
23	Can delete image	6	delete_image
24	Can view image	6	view_image
25	Can add image set	7	add_imageset
26	Can change image set	7	change_imageset
27	Can delete image set	7	delete_imageset
28	Can view image set	7	view_imageset
29	Can add set tag	8	add_settag
30	Can change set tag	8	change_settag
31	Can delete set tag	8	delete_settag
32	Can view set tag	8	view_settag
33	Can add user	9	add_user
34	Can change user	9	change_user
35	Can delete user	9	delete_user
36	Can view user	9	view_user
37	Can add team	10	add_team
38	Can change team	10	change_team
39	Can delete team	10	delete_team
40	Can view team	10	view_team
41	Can add team membership	11	add_teammembership
42	Can change team membership	11	change_teammembership
43	Can delete team membership	11	delete_teammembership
44	Can view team membership	11	view_teammembership
45	Can add tool	12	add_tool
46	Can change tool	12	change_tool
47	Can delete tool	12	delete_tool
48	Can view tool	12	view_tool
49	Can add tool vote	13	add_toolvote
50	Can change tool vote	13	change_toolvote
51	Can delete tool vote	13	delete_toolvote
52	Can view tool vote	13	view_toolvote
53	Can add log entry	14	add_logentry
54	Can change log entry	14	change_logentry
55	Can delete log entry	14	delete_logentry
56	Can view log entry	14	view_logentry
57	Can add message	15	add_message
58	Can change message	15	change_message
59	Can delete message	15	delete_message
60	Can view message	15	view_message
61	Can add global message	16	add_globalmessage
62	Can change global message	16	change_globalmessage
63	Can delete global message	16	delete_globalmessage
64	Can view global message	16	view_globalmessage
65	Can add team message	17	add_teammessage
66	Can change team message	17	change_teammessage
67	Can delete team message	17	delete_teammessage
68	Can view team message	17	view_teammessage
69	Can add permission	18	add_permission
70	Can change permission	18	change_permission
71	Can delete permission	18	delete_permission
72	Can view permission	18	view_permission
73	Can add group	19	add_group
74	Can change group	19	change_group
75	Can delete group	19	delete_group
76	Can view group	19	view_group
77	Can add content type	20	add_contenttype
78	Can change content type	20	change_contenttype
79	Can delete content type	20	delete_contenttype
80	Can view content type	20	view_contenttype
81	Can add session	21	add_session
82	Can change session	21	change_session
83	Can delete session	21	delete_session
84	Can view session	21	view_session
\.


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	annotations	annotation
2	annotations	annotationtype
3	annotations	export
4	annotations	verification
5	annotations	exportformat
6	images	image
7	images	imageset
8	images	settag
9	users	user
10	users	team
11	users	teammembership
12	tools	tool
13	tools	toolvote
14	admin	logentry
15	tagger_messages	message
16	tagger_messages	globalmessage
17	tagger_messages	teammessage
18	auth	permission
19	auth	group
20	contenttypes	contenttype
21	sessions	session
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2020-03-11 21:42:38.005775+08
2	contenttypes	0002_remove_content_type_name	2020-03-11 21:42:38.014747+08
3	auth	0001_initial	2020-03-11 21:42:38.345836+08
4	auth	0002_alter_permission_name_max_length	2020-03-11 21:42:38.758733+08
5	auth	0003_alter_user_email_max_length	2020-03-11 21:42:38.76372+08
6	auth	0004_alter_user_username_opts	2020-03-11 21:42:38.768707+08
7	auth	0005_alter_user_last_login_null	2020-03-11 21:42:38.77469+08
8	auth	0006_require_contenttypes_0002	2020-03-11 21:42:38.809597+08
9	auth	0007_alter_validators_add_error_messages	2020-03-11 21:42:38.814583+08
10	auth	0008_alter_user_username_max_length	2020-03-11 21:42:38.820568+08
11	auth	0009_alter_user_last_name_max_length	2020-03-11 21:42:38.824557+08
12	users	0001_initial	2020-03-11 21:42:39.772048+08
13	admin	0001_initial	2020-03-11 21:42:40.705582+08
14	admin	0002_logentry_remove_auto_add	2020-03-11 21:42:40.870137+08
15	admin	0003_logentry_add_action_flag_choices	2020-03-11 21:42:40.877145+08
16	images	0001_initial	2020-03-11 21:42:41.354968+08
17	annotations	0001_initial	2020-03-11 21:42:42.214762+08
18	annotations	0002_auto_20170822_1159	2020-03-11 21:42:42.471101+08
19	annotations	0003_auto_20170826_1207	2020-03-11 21:42:42.941819+08
20	annotations	0004_auto_20170826_1211	2020-03-11 21:42:43.073466+08
21	annotations	0005_auto_20170826_1424	2020-03-11 21:42:43.097403+08
22	annotations	0006_auto_20170826_1431	2020-03-11 21:42:43.126325+08
23	annotations	0007_auto_20170826_1446	2020-03-11 21:42:43.143307+08
24	annotations	0008_auto_20170826_1533	2020-03-11 21:42:43.170208+08
25	annotations	0009_auto_20170826_1535	2020-03-11 21:42:43.18417+08
26	annotations	0010_auto_20170828_1628	2020-03-11 21:42:43.809499+08
27	annotations	0011_remove_export_export_type	2020-03-11 21:42:44.312402+08
28	annotations	0012_exportformat_not_in_image_format	2020-03-11 21:42:44.947835+08
29	annotations	0013_exportformat_min_verifications	2020-03-11 21:42:45.390808+08
30	annotations	0014_auto_20170907_1407	2020-03-11 21:42:45.409756+08
31	annotations	0015_auto_20171129_1511	2020-03-11 21:42:45.9295+08
32	annotations	0016_auto_20171213_1115	2020-03-11 21:42:45.948449+08
33	annotations	0017_auto_20171220_1938	2020-03-11 21:42:46.856022+08
34	annotations	0018_auto_20171220_2020	2020-03-11 21:42:47.299012+08
35	annotations	0019_auto_20180314_0922	2020-03-11 21:42:47.326907+08
36	annotations	0020_auto_20180417_1220	2020-03-11 21:42:47.981157+08
37	annotations	0021_exportformat_vector_format	2020-03-11 21:42:48.37318+08
38	annotations	0022_auto_20180425_1409	2020-03-11 21:42:48.383153+08
39	annotations	0023_auto_20180428_1756	2020-03-11 21:42:48.890888+08
40	annotations	0024_auto_20180429_0005	2020-03-11 21:42:48.911832+08
41	annotations	export_format_conversion_20180504	2020-03-11 21:42:48.924797+08
42	annotations	0001_auto_20180508_1215	2020-03-11 21:42:50.390901+08
43	annotations	0002_auto_20180510_2310	2020-03-11 21:42:51.141027+08
44	annotations	0025_points_trigger	2020-03-11 21:42:51.151+08
45	annotations	0026_index_verification_time	2020-03-11 21:42:51.273673+08
46	annotations	0027_auto_20181114_1058	2020-03-11 21:42:51.281651+08
47	auth	0010_alter_group_name_max_length	2020-03-11 21:42:51.288633+08
48	auth	0011_update_proxy_permissions	2020-03-11 21:42:51.300601+08
49	images	0002_auto_20170822_1159	2020-03-11 21:42:51.50306+08
50	images	0003_auto_20170825_1012	2020-03-11 21:42:51.685572+08
51	images	0004_auto_20170825_1114	2020-03-11 21:42:51.790292+08
52	images	0005_auto_20170825_1129	2020-03-11 21:42:51.809241+08
53	images	0006_auto_20170825_1148	2020-03-11 21:42:51.826195+08
54	images	0007_auto_20170830_1626	2020-03-11 21:42:52.59936+08
55	images	0008_auto_20171120_1056	2020-03-11 21:42:52.618328+08
56	images	0009_auto_20171122_1504	2020-03-11 21:42:52.635263+08
57	images	0010_imageset_public_collaboration	2020-03-11 21:42:53.182883+08
58	images	0011_auto_20180507_1830	2020-03-11 21:42:53.676695+08
59	images	0012_imageset_creator	2020-03-11 21:42:53.780446+08
60	images	0013_settag	2020-03-11 21:42:54.219273+08
61	images	0014_auto_20180629_2250	2020-03-11 21:42:54.633166+08
62	images	0015_imageset_pinned_by	2020-03-11 21:42:54.732907+08
63	images	0016_settag_test	2020-03-11 21:42:54.959295+08
64	images	0017_imageset_zip_state	2020-03-11 21:42:55.770642+08
65	sessions	0001_initial	2020-03-11 21:42:56.058002+08
66	users	0002_user_points	2020-03-11 21:42:56.500844+08
67	tagger_messages	0001_initial	2020-03-11 21:42:57.217172+08
68	tools	0001_initial	2020-03-11 21:42:58.033266+08
69	tools	0002_tool_public	2020-03-11 21:42:58.871149+08
70	tools	0003_auto_20171222_0302	2020-03-11 21:42:58.922016+08
71	annotations	0028_auto_20200313_0144	2020-03-13 17:58:57.85009+08
72	annotations	0029_auto_20200313_0145	2020-03-13 17:58:57.968773+08
73	annotations	0030_auto_20200313_1455	2020-03-13 17:58:57.993706+08
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
o7e6ibu33lokbn2flt9lgoyeu02m74g4	MzM1MGFmYzRiZjk1YjllNDBhMjdiZjdiZDBiMTRmOWRmN2UzY2NmYjp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIwNjQ1ZWMwMDE3MzQ5NTM3NmI4MWI5OGJmNDlmNWZhODQwNWYyYmM5In0=	2020-03-28 23:06:02.061295+08
\.


--
-- Data for Name: images_image; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.images_image (id, name, filename, "time", checksum, image_set_id, height, width) FROM stdin;
7	color_white_offwhite.jpg	color_white_offwhite_amWesd.jpg	2020-03-14 20:39:07.992367+08	\\x7ce954a83af1e2b390eb92cdb615bc3398c9c30c1d327f5fb8310fd61c92fe6cab3fcd9ae39bb373ad17fce247e15cdd40ef093df4b5f7b35dc397c0a2380afb	3	750	500
8	products_skirt_skirt-longcolors_orange_orange-carrot.jpg	products_skirt_skirt-longcolors_orange_orange-carrot_WQ4b0N.jpg	2020-03-14 20:39:08.070159+08	\\x36684c91a0e207c942b489f87b24b5c0301c9c1790a92ef721ccf94a5104f1eb5e5af60326e8b748b05d4a7438f37b1ab9b5be32c101019dba810b0fa453aed8	3	2048	1065
9	run.jpg	run_lyog05.jpg	2020-03-14 20:39:08.141967+08	\\x3c2a1f9f682f3f28c7366e414ed4ae1567c32cb854886cec16cfe0b19508bbaf2b39b798403131bc5748b2604f78addf59d5c93c6057c51c1e9eabc25723c0bc	3	987	658
10	timg.jpg	timg_LZVIwS.jpg	2020-03-14 20:39:08.214773+08	\\xee0b47b4c9fc2ed682e4b0a5f82034e9dd80b0e8b0a59abe8b33ee6b941b474cedc51069dffe4bf2d2ab6d9aac027b492ca8938a7187430428222bfe30a958cb	3	1800	1200
\.


--
-- Data for Name: images_imageset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.images_imageset (id, path, name, location, description, "time", public, image_lock, team_id, public_collaboration, main_annotation_type_id, priority, creator_id, zip_state) FROM stdin;
3	1_3	2020Spring	shanghai		2020-03-14 20:38:58.322014+08	f	f	1	f	\N	0	1	0
\.


--
-- Data for Name: images_imageset_pinned_by; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.images_imageset_pinned_by (id, imageset_id, user_id) FROM stdin;
\.


--
-- Data for Name: images_settag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.images_settag (id, name) FROM stdin;
1	test
\.


--
-- Data for Name: images_settag_imagesets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.images_settag_imagesets (id, settag_id, imageset_id) FROM stdin;
\.


--
-- Data for Name: tagger_messages_globalmessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tagger_messages_globalmessage (message_ptr_id, team_admins_only, staff_only) FROM stdin;
\.


--
-- Data for Name: tagger_messages_message; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tagger_messages_message (id, title, content, creation_time, start_time, expire_time, creator_id) FROM stdin;
\.


--
-- Data for Name: tagger_messages_message_read_by; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tagger_messages_message_read_by (id, message_id, user_id) FROM stdin;
\.


--
-- Data for Name: tagger_messages_teammessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tagger_messages_teammessage (message_ptr_id, admins_only, team_id) FROM stdin;
\.


--
-- Data for Name: tools_tool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tools_tool (id, name, filename, description, creation_date, creator_id, team_id, public) FROM stdin;
14	catalog0	14_showonly.xlsx	123	2020-03-14 22:09:06.637898+08	1	1	f
16	test0	16_catalog.xlsx	123	2020-03-14 23:06:00.834676+08	1	1	f
17	test0	17_catalog.xlsx	123	2020-03-14 23:38:54.301328+08	1	1	f
\.


--
-- Data for Name: tools_toolvote; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tools_toolvote (id, "time", positive, tool_id, user_id) FROM stdin;
\.


--
-- Data for Name: users_team; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_team (id, name, website) FROM stdin;
1	FDB	
\.


--
-- Data for Name: users_teammembership; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_teammembership (id, is_admin, team_id, user_id) FROM stdin;
1	t	1	1
\.


--
-- Data for Name: users_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined, points) FROM stdin;
1	pbkdf2_sha256$150000$tSI24wc4chq5$8iaumLcvyqGSYoz5aBBg/R90SOCrdIiPd5TU4lZt3uQ=	2020-03-14 23:03:10.389782+08	f	eve			yejj@shanghaitech.edu.cn	f	t	2020-03-11 21:43:45.225324+08	2
\.


--
-- Data for Name: users_user_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- Data for Name: users_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- Name: annotations_annotation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.annotations_annotation_id_seq', 13, true);


--
-- Name: annotations_annotationtype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.annotations_annotationtype_id_seq', 1, false);


--
-- Name: annotations_export_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.annotations_export_id_seq', 5, true);


--
-- Name: annotations_exportformat_annotations_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.annotations_exportformat_annotations_types_id_seq', 2, true);


--
-- Name: annotations_exportformat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.annotations_exportformat_id_seq', 2, true);


--
-- Name: annotations_verification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.annotations_verification_id_seq', 13, true);


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 84, true);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 1, false);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 21, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 73, true);


--
-- Name: images_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.images_image_id_seq', 10, true);


--
-- Name: images_imageset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.images_imageset_id_seq', 3, true);


--
-- Name: images_imageset_pinned_by_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.images_imageset_pinned_by_id_seq', 1, false);


--
-- Name: images_settag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.images_settag_id_seq', 1, true);


--
-- Name: images_settag_imagesets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.images_settag_imagesets_id_seq', 1, false);


--
-- Name: tagger_messages_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tagger_messages_message_id_seq', 1, false);


--
-- Name: tagger_messages_message_read_by_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tagger_messages_message_read_by_id_seq', 1, false);


--
-- Name: tools_tool_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tools_tool_id_seq', 17, true);


--
-- Name: tools_toolvote_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tools_toolvote_id_seq', 1, false);


--
-- Name: users_team_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_team_id_seq', 1, true);


--
-- Name: users_teammembership_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_teammembership_id_seq', 1, true);


--
-- Name: users_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_groups_id_seq', 1, false);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 1, true);


--
-- Name: users_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_user_permissions_id_seq', 1, false);


--
-- Name: annotations_annotation annotations_annotation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_annotation
    ADD CONSTRAINT annotations_annotation_pkey PRIMARY KEY (id);


--
-- Name: annotations_annotationtype annotations_annotationtype_L2code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_annotationtype
    ADD CONSTRAINT "annotations_annotationtype_L2code_key" UNIQUE ("L2code");


--
-- Name: annotations_annotationtype annotations_annotationtype_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_annotationtype
    ADD CONSTRAINT annotations_annotationtype_name_key UNIQUE (name);


--
-- Name: annotations_annotationtype annotations_annotationtype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_annotationtype
    ADD CONSTRAINT annotations_annotationtype_pkey PRIMARY KEY (id);


--
-- Name: annotations_export annotations_export_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_export
    ADD CONSTRAINT annotations_export_pkey PRIMARY KEY (id);


--
-- Name: annotations_exportformat_annotations_types annotations_exportformat_annotations_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_exportformat_annotations_types
    ADD CONSTRAINT annotations_exportformat_annotations_types_pkey PRIMARY KEY (id);


--
-- Name: annotations_exportformat_annotations_types annotations_exportformat_exportformat_id_annotati_6f53dfcb_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_exportformat_annotations_types
    ADD CONSTRAINT annotations_exportformat_exportformat_id_annotati_6f53dfcb_uniq UNIQUE (exportformat_id, annotationtype_id);


--
-- Name: annotations_exportformat annotations_exportformat_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_exportformat
    ADD CONSTRAINT annotations_exportformat_name_key UNIQUE (name);


--
-- Name: annotations_exportformat annotations_exportformat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_exportformat
    ADD CONSTRAINT annotations_exportformat_pkey PRIMARY KEY (id);


--
-- Name: annotations_verification annotations_verification_annotation_id_user_id_b9c9e1c2_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_verification
    ADD CONSTRAINT annotations_verification_annotation_id_user_id_b9c9e1c2_uniq UNIQUE (annotation_id, user_id);


--
-- Name: annotations_verification annotations_verification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_verification
    ADD CONSTRAINT annotations_verification_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: images_image images_image_filename_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_image
    ADD CONSTRAINT images_image_filename_key UNIQUE (filename);


--
-- Name: images_image images_image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_image
    ADD CONSTRAINT images_image_pkey PRIMARY KEY (id);


--
-- Name: images_imageset images_imageset_name_team_id_94e7e2c4_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_imageset
    ADD CONSTRAINT images_imageset_name_team_id_94e7e2c4_uniq UNIQUE (name, team_id);


--
-- Name: images_imageset images_imageset_path_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_imageset
    ADD CONSTRAINT images_imageset_path_key UNIQUE (path);


--
-- Name: images_imageset_pinned_by images_imageset_pinned_by_imageset_id_user_id_803c990f_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_imageset_pinned_by
    ADD CONSTRAINT images_imageset_pinned_by_imageset_id_user_id_803c990f_uniq UNIQUE (imageset_id, user_id);


--
-- Name: images_imageset_pinned_by images_imageset_pinned_by_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_imageset_pinned_by
    ADD CONSTRAINT images_imageset_pinned_by_pkey PRIMARY KEY (id);


--
-- Name: images_imageset images_imageset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_imageset
    ADD CONSTRAINT images_imageset_pkey PRIMARY KEY (id);


--
-- Name: images_settag_imagesets images_settag_imagesets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_settag_imagesets
    ADD CONSTRAINT images_settag_imagesets_pkey PRIMARY KEY (id);


--
-- Name: images_settag_imagesets images_settag_imagesets_settag_id_imageset_id_513eecba_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_settag_imagesets
    ADD CONSTRAINT images_settag_imagesets_settag_id_imageset_id_513eecba_uniq UNIQUE (settag_id, imageset_id);


--
-- Name: images_settag images_settag_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_settag
    ADD CONSTRAINT images_settag_name_key UNIQUE (name);


--
-- Name: images_settag images_settag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_settag
    ADD CONSTRAINT images_settag_pkey PRIMARY KEY (id);


--
-- Name: tagger_messages_globalmessage tagger_messages_globalmessage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagger_messages_globalmessage
    ADD CONSTRAINT tagger_messages_globalmessage_pkey PRIMARY KEY (message_ptr_id);


--
-- Name: tagger_messages_message_read_by tagger_messages_message__message_id_user_id_9c8cfded_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagger_messages_message_read_by
    ADD CONSTRAINT tagger_messages_message__message_id_user_id_9c8cfded_uniq UNIQUE (message_id, user_id);


--
-- Name: tagger_messages_message tagger_messages_message_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagger_messages_message
    ADD CONSTRAINT tagger_messages_message_pkey PRIMARY KEY (id);


--
-- Name: tagger_messages_message_read_by tagger_messages_message_read_by_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagger_messages_message_read_by
    ADD CONSTRAINT tagger_messages_message_read_by_pkey PRIMARY KEY (id);


--
-- Name: tagger_messages_teammessage tagger_messages_teammessage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagger_messages_teammessage
    ADD CONSTRAINT tagger_messages_teammessage_pkey PRIMARY KEY (message_ptr_id);


--
-- Name: tools_tool tools_tool_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tools_tool
    ADD CONSTRAINT tools_tool_pkey PRIMARY KEY (id);


--
-- Name: tools_toolvote tools_toolvote_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tools_toolvote
    ADD CONSTRAINT tools_toolvote_pkey PRIMARY KEY (id);


--
-- Name: tools_toolvote tools_toolvote_tool_id_user_id_862b111c_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tools_toolvote
    ADD CONSTRAINT tools_toolvote_tool_id_user_id_862b111c_uniq UNIQUE (tool_id, user_id);


--
-- Name: users_team users_team_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_team
    ADD CONSTRAINT users_team_name_key UNIQUE (name);


--
-- Name: users_team users_team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_team
    ADD CONSTRAINT users_team_pkey PRIMARY KEY (id);


--
-- Name: users_teammembership users_teammembership_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_teammembership
    ADD CONSTRAINT users_teammembership_pkey PRIMARY KEY (id);


--
-- Name: users_user_groups users_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_groups
    ADD CONSTRAINT users_user_groups_pkey PRIMARY KEY (id);


--
-- Name: users_user_groups users_user_groups_user_id_group_id_b88eab82_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_groups
    ADD CONSTRAINT users_user_groups_user_id_group_id_b88eab82_uniq UNIQUE (user_id, group_id);


--
-- Name: users_user users_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user
    ADD CONSTRAINT users_user_pkey PRIMARY KEY (id);


--
-- Name: users_user_user_permissions users_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_user_permissions
    ADD CONSTRAINT users_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: users_user_user_permissions users_user_user_permissions_user_id_permission_id_43338c45_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_user_permissions
    ADD CONSTRAINT users_user_user_permissions_user_id_permission_id_43338c45_uniq UNIQUE (user_id, permission_id);


--
-- Name: users_user users_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user
    ADD CONSTRAINT users_user_username_key UNIQUE (username);


--
-- Name: annotations_annotation_image_id_0b6db3d6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_annotation_image_id_0b6db3d6 ON public.annotations_annotation USING btree (image_id);


--
-- Name: annotations_annotation_last_editor_id_0657f4d7; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_annotation_last_editor_id_0657f4d7 ON public.annotations_annotation USING btree (last_editor_id);


--
-- Name: annotations_annotation_type_id_2ff9f300; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_annotation_type_id_2ff9f300 ON public.annotations_annotation USING btree (annotation_type_id);


--
-- Name: annotations_annotation_user_id_408b8473; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_annotation_user_id_408b8473 ON public.annotations_annotation USING btree (user_id);


--
-- Name: annotations_annotationtype_L2code_7a399de6_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "annotations_annotationtype_L2code_7a399de6_like" ON public.annotations_annotationtype USING btree ("L2code" varchar_pattern_ops);


--
-- Name: annotations_annotationtype_name_a8204125_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_annotationtype_name_a8204125_like ON public.annotations_annotationtype USING btree (name varchar_pattern_ops);


--
-- Name: annotations_export_format_id_9a683ed4; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_export_format_id_9a683ed4 ON public.annotations_export USING btree (format_id);


--
-- Name: annotations_export_image_set_id_e45097b9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_export_image_set_id_e45097b9 ON public.annotations_export USING btree (image_set_id);


--
-- Name: annotations_export_user_id_f2bd5a53; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_export_user_id_f2bd5a53 ON public.annotations_export USING btree (user_id);


--
-- Name: annotations_exportformat_a_annotationtype_id_ed88c181; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_exportformat_a_annotationtype_id_ed88c181 ON public.annotations_exportformat_annotations_types USING btree (annotationtype_id);


--
-- Name: annotations_exportformat_a_exportformat_id_82c17369; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_exportformat_a_exportformat_id_82c17369 ON public.annotations_exportformat_annotations_types USING btree (exportformat_id);


--
-- Name: annotations_exportformat_name_36136201_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_exportformat_name_36136201_like ON public.annotations_exportformat USING btree (name varchar_pattern_ops);


--
-- Name: annotations_exportformat_team_id_29cc3456; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_exportformat_team_id_29cc3456 ON public.annotations_exportformat USING btree (team_id);


--
-- Name: annotations_verification_annotation_id_c59809c1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_verification_annotation_id_c59809c1 ON public.annotations_verification USING btree (annotation_id);


--
-- Name: annotations_verification_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_verification_time ON public.annotations_verification USING btree ("time");


--
-- Name: annotations_verification_user_id_06091272; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX annotations_verification_user_id_06091272 ON public.annotations_verification USING btree (user_id);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: images_image_filename_911b069a_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX images_image_filename_911b069a_like ON public.images_image USING btree (filename varchar_pattern_ops);


--
-- Name: images_image_image_set_id_840e3711; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX images_image_image_set_id_840e3711 ON public.images_image USING btree (image_set_id);


--
-- Name: images_imageset_creator_id_9e4c4dc4; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX images_imageset_creator_id_9e4c4dc4 ON public.images_imageset USING btree (creator_id);


--
-- Name: images_imageset_main_annotation_type_id_8afe6552; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX images_imageset_main_annotation_type_id_8afe6552 ON public.images_imageset USING btree (main_annotation_type_id);


--
-- Name: images_imageset_path_9009b3e6_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX images_imageset_path_9009b3e6_like ON public.images_imageset USING btree (path varchar_pattern_ops);


--
-- Name: images_imageset_pinned_by_imageset_id_06684311; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX images_imageset_pinned_by_imageset_id_06684311 ON public.images_imageset_pinned_by USING btree (imageset_id);


--
-- Name: images_imageset_pinned_by_user_id_0f520674; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX images_imageset_pinned_by_user_id_0f520674 ON public.images_imageset_pinned_by USING btree (user_id);


--
-- Name: images_imageset_team_id_7addade8; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX images_imageset_team_id_7addade8 ON public.images_imageset USING btree (team_id);


--
-- Name: images_settag_imagesets_imageset_id_83719e2a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX images_settag_imagesets_imageset_id_83719e2a ON public.images_settag_imagesets USING btree (imageset_id);


--
-- Name: images_settag_imagesets_settag_id_8952e3e8; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX images_settag_imagesets_settag_id_8952e3e8 ON public.images_settag_imagesets USING btree (settag_id);


--
-- Name: images_settag_name_4822cb4d_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX images_settag_name_4822cb4d_like ON public.images_settag USING btree (name varchar_pattern_ops);


--
-- Name: tagger_messages_message_creator_id_be6ff0c7; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagger_messages_message_creator_id_be6ff0c7 ON public.tagger_messages_message USING btree (creator_id);


--
-- Name: tagger_messages_message_read_by_message_id_afb90baa; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagger_messages_message_read_by_message_id_afb90baa ON public.tagger_messages_message_read_by USING btree (message_id);


--
-- Name: tagger_messages_message_read_by_user_id_fb22e6ae; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagger_messages_message_read_by_user_id_fb22e6ae ON public.tagger_messages_message_read_by USING btree (user_id);


--
-- Name: tagger_messages_teammessage_team_id_6c76b2c1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tagger_messages_teammessage_team_id_6c76b2c1 ON public.tagger_messages_teammessage USING btree (team_id);


--
-- Name: tools_tool_creator_id_2ca55d54; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tools_tool_creator_id_2ca55d54 ON public.tools_tool USING btree (creator_id);


--
-- Name: tools_tool_team_id_2affaaa9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tools_tool_team_id_2affaaa9 ON public.tools_tool USING btree (team_id);


--
-- Name: tools_toolvote_tool_id_3c989b9a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tools_toolvote_tool_id_3c989b9a ON public.tools_toolvote USING btree (tool_id);


--
-- Name: tools_toolvote_user_id_089c3590; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tools_toolvote_user_id_089c3590 ON public.tools_toolvote USING btree (user_id);


--
-- Name: users_team_name_a6d3449e_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_team_name_a6d3449e_like ON public.users_team USING btree (name varchar_pattern_ops);


--
-- Name: users_teammembership_team_id_21b79acc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_teammembership_team_id_21b79acc ON public.users_teammembership USING btree (team_id);


--
-- Name: users_teammembership_user_id_20b42042; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_teammembership_user_id_20b42042 ON public.users_teammembership USING btree (user_id);


--
-- Name: users_user_groups_group_id_9afc8d0e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_groups_group_id_9afc8d0e ON public.users_user_groups USING btree (group_id);


--
-- Name: users_user_groups_user_id_5f6f5a90; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_groups_user_id_5f6f5a90 ON public.users_user_groups USING btree (user_id);


--
-- Name: users_user_user_permissions_permission_id_0b93982e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_user_permissions_permission_id_0b93982e ON public.users_user_user_permissions USING btree (permission_id);


--
-- Name: users_user_user_permissions_user_id_20aca447; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_user_permissions_user_id_20aca447 ON public.users_user_user_permissions USING btree (user_id);


--
-- Name: users_user_username_06e46fe6_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_user_username_06e46fe6_like ON public.users_user USING btree (username varchar_pattern_ops);


--
-- Name: annotations_verification points_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER points_update AFTER INSERT OR DELETE OR UPDATE OF verified, annotation_id ON public.annotations_verification FOR EACH ROW EXECUTE PROCEDURE public.update_points();


--
-- Name: annotations_annotation annotations_annotati_annotation_type_id_425bbec1_fk_annotatio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_annotation
    ADD CONSTRAINT annotations_annotati_annotation_type_id_425bbec1_fk_annotatio FOREIGN KEY (annotation_type_id) REFERENCES public.annotations_annotationtype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: annotations_annotation annotations_annotation_image_id_0b6db3d6_fk_images_image_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_annotation
    ADD CONSTRAINT annotations_annotation_image_id_0b6db3d6_fk_images_image_id FOREIGN KEY (image_id) REFERENCES public.images_image(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: annotations_annotation annotations_annotation_last_editor_id_0657f4d7_fk_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_annotation
    ADD CONSTRAINT annotations_annotation_last_editor_id_0657f4d7_fk_users_user_id FOREIGN KEY (last_editor_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: annotations_annotation annotations_annotation_user_id_408b8473_fk_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_annotation
    ADD CONSTRAINT annotations_annotation_user_id_408b8473_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: annotations_export annotations_export_format_id_9a683ed4_fk_annotatio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_export
    ADD CONSTRAINT annotations_export_format_id_9a683ed4_fk_annotatio FOREIGN KEY (format_id) REFERENCES public.annotations_exportformat(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: annotations_export annotations_export_image_set_id_e45097b9_fk_images_imageset_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_export
    ADD CONSTRAINT annotations_export_image_set_id_e45097b9_fk_images_imageset_id FOREIGN KEY (image_set_id) REFERENCES public.images_imageset(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: annotations_export annotations_export_user_id_f2bd5a53_fk_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_export
    ADD CONSTRAINT annotations_export_user_id_f2bd5a53_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: annotations_exportformat_annotations_types annotations_exportfo_annotationtype_id_ed88c181_fk_annotatio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_exportformat_annotations_types
    ADD CONSTRAINT annotations_exportfo_annotationtype_id_ed88c181_fk_annotatio FOREIGN KEY (annotationtype_id) REFERENCES public.annotations_annotationtype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: annotations_exportformat_annotations_types annotations_exportfo_exportformat_id_82c17369_fk_annotatio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_exportformat_annotations_types
    ADD CONSTRAINT annotations_exportfo_exportformat_id_82c17369_fk_annotatio FOREIGN KEY (exportformat_id) REFERENCES public.annotations_exportformat(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: annotations_exportformat annotations_exportformat_team_id_29cc3456_fk_users_team_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_exportformat
    ADD CONSTRAINT annotations_exportformat_team_id_29cc3456_fk_users_team_id FOREIGN KEY (team_id) REFERENCES public.users_team(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: annotations_verification annotations_verifica_annotation_id_c59809c1_fk_annotatio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_verification
    ADD CONSTRAINT annotations_verifica_annotation_id_c59809c1_fk_annotatio FOREIGN KEY (annotation_id) REFERENCES public.annotations_annotation(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: annotations_verification annotations_verification_user_id_06091272_fk_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.annotations_verification
    ADD CONSTRAINT annotations_verification_user_id_06091272_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: images_image images_image_image_set_id_840e3711_fk_images_imageset_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_image
    ADD CONSTRAINT images_image_image_set_id_840e3711_fk_images_imageset_id FOREIGN KEY (image_set_id) REFERENCES public.images_imageset(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: images_imageset images_imageset_creator_id_9e4c4dc4_fk_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_imageset
    ADD CONSTRAINT images_imageset_creator_id_9e4c4dc4_fk_users_user_id FOREIGN KEY (creator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: images_imageset images_imageset_main_annotation_type_8afe6552_fk_annotatio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_imageset
    ADD CONSTRAINT images_imageset_main_annotation_type_8afe6552_fk_annotatio FOREIGN KEY (main_annotation_type_id) REFERENCES public.annotations_annotationtype(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: images_imageset_pinned_by images_imageset_pinn_imageset_id_06684311_fk_images_im; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_imageset_pinned_by
    ADD CONSTRAINT images_imageset_pinn_imageset_id_06684311_fk_images_im FOREIGN KEY (imageset_id) REFERENCES public.images_imageset(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: images_imageset_pinned_by images_imageset_pinned_by_user_id_0f520674_fk_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_imageset_pinned_by
    ADD CONSTRAINT images_imageset_pinned_by_user_id_0f520674_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: images_imageset images_imageset_team_id_7addade8_fk_users_team_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_imageset
    ADD CONSTRAINT images_imageset_team_id_7addade8_fk_users_team_id FOREIGN KEY (team_id) REFERENCES public.users_team(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: images_settag_imagesets images_settag_images_imageset_id_83719e2a_fk_images_im; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_settag_imagesets
    ADD CONSTRAINT images_settag_images_imageset_id_83719e2a_fk_images_im FOREIGN KEY (imageset_id) REFERENCES public.images_imageset(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: images_settag_imagesets images_settag_imagesets_settag_id_8952e3e8_fk_images_settag_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images_settag_imagesets
    ADD CONSTRAINT images_settag_imagesets_settag_id_8952e3e8_fk_images_settag_id FOREIGN KEY (settag_id) REFERENCES public.images_settag(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tagger_messages_globalmessage tagger_messages_glob_message_ptr_id_2bf1f2e5_fk_tagger_me; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagger_messages_globalmessage
    ADD CONSTRAINT tagger_messages_glob_message_ptr_id_2bf1f2e5_fk_tagger_me FOREIGN KEY (message_ptr_id) REFERENCES public.tagger_messages_message(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tagger_messages_message_read_by tagger_messages_mess_message_id_afb90baa_fk_tagger_me; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagger_messages_message_read_by
    ADD CONSTRAINT tagger_messages_mess_message_id_afb90baa_fk_tagger_me FOREIGN KEY (message_id) REFERENCES public.tagger_messages_message(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tagger_messages_message_read_by tagger_messages_mess_user_id_fb22e6ae_fk_users_use; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagger_messages_message_read_by
    ADD CONSTRAINT tagger_messages_mess_user_id_fb22e6ae_fk_users_use FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tagger_messages_message tagger_messages_message_creator_id_be6ff0c7_fk_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagger_messages_message
    ADD CONSTRAINT tagger_messages_message_creator_id_be6ff0c7_fk_users_user_id FOREIGN KEY (creator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tagger_messages_teammessage tagger_messages_team_message_ptr_id_bcefca47_fk_tagger_me; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagger_messages_teammessage
    ADD CONSTRAINT tagger_messages_team_message_ptr_id_bcefca47_fk_tagger_me FOREIGN KEY (message_ptr_id) REFERENCES public.tagger_messages_message(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tagger_messages_teammessage tagger_messages_teammessage_team_id_6c76b2c1_fk_users_team_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tagger_messages_teammessage
    ADD CONSTRAINT tagger_messages_teammessage_team_id_6c76b2c1_fk_users_team_id FOREIGN KEY (team_id) REFERENCES public.users_team(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tools_tool tools_tool_creator_id_2ca55d54_fk_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tools_tool
    ADD CONSTRAINT tools_tool_creator_id_2ca55d54_fk_users_user_id FOREIGN KEY (creator_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tools_tool tools_tool_team_id_2affaaa9_fk_users_team_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tools_tool
    ADD CONSTRAINT tools_tool_team_id_2affaaa9_fk_users_team_id FOREIGN KEY (team_id) REFERENCES public.users_team(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tools_toolvote tools_toolvote_tool_id_3c989b9a_fk_tools_tool_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tools_toolvote
    ADD CONSTRAINT tools_toolvote_tool_id_3c989b9a_fk_tools_tool_id FOREIGN KEY (tool_id) REFERENCES public.tools_tool(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tools_toolvote tools_toolvote_user_id_089c3590_fk_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tools_toolvote
    ADD CONSTRAINT tools_toolvote_user_id_089c3590_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: users_teammembership users_teammembership_team_id_21b79acc_fk_users_team_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_teammembership
    ADD CONSTRAINT users_teammembership_team_id_21b79acc_fk_users_team_id FOREIGN KEY (team_id) REFERENCES public.users_team(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: users_teammembership users_teammembership_user_id_20b42042_fk_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_teammembership
    ADD CONSTRAINT users_teammembership_user_id_20b42042_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: users_user_groups users_user_groups_group_id_9afc8d0e_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_groups
    ADD CONSTRAINT users_user_groups_group_id_9afc8d0e_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: users_user_groups users_user_groups_user_id_5f6f5a90_fk_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_groups
    ADD CONSTRAINT users_user_groups_user_id_5f6f5a90_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: users_user_user_permissions users_user_user_perm_permission_id_0b93982e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_user_permissions
    ADD CONSTRAINT users_user_user_perm_permission_id_0b93982e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: users_user_user_permissions users_user_user_permissions_user_id_20aca447_fk_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_user_user_permissions
    ADD CONSTRAINT users_user_user_permissions_user_id_20aca447_fk_users_user_id FOREIGN KEY (user_id) REFERENCES public.users_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

