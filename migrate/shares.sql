--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: shares; Type: TABLE; Schema: public; Owner: namecoin; Tablespace: 
--

CREATE TABLE shares (
    id integer NOT NULL,
    rem_host text,
    username text,
    our_result boolean,
    upstream_result boolean,
    reason text,
    solution text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.shares OWNER TO namecoin;

--
-- Name: shares_id_seq; Type: SEQUENCE; Schema: public; Owner: namecoin
--

CREATE SEQUENCE shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shares_id_seq OWNER TO namecoin;

--
-- Name: shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: namecoin
--

ALTER SEQUENCE shares_id_seq OWNED BY shares.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: namecoin
--

ALTER TABLE shares ALTER COLUMN id SET DEFAULT nextval('shares_id_seq'::regclass);


--
-- Name: shares_pkey; Type: CONSTRAINT; Schema: public; Owner: namecoin; Tablespace: 
--

ALTER TABLE ONLY shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

