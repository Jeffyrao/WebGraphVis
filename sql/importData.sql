connect 'jdbc:derby://localhost:1527/warcbase;create=true;';

-- add database user/password as rjf/rjf
CALL SYSCS_UTIL.SYSCS_SET_DATABASE_PROPERTY(
    'derby.user.rjf', 'rjf');
    
DROP TABLE APP.LINKS;
DROP TABLE APP.NODES;

CREATE TABLE APP.NODES(
	id varchar(20) NOT NULL primary key,
	name varchar(150),
	pagerank varchar(20) NOT NULL, 
	url varchar(200) NOT NULL,
	party char(20),
	committee char(20),
	state varchar(20),
	district varchar(20)
);

--import nodes.csv data to table APP.NODES;
CALL SYSCS_UTIL.SYSCS_IMPORT_TABLE
('APP', 'NODES','data/nodes.csv',',',null,null, 0);
--delete column header
DELETE from APP.NODES WHERE id='id';

CREATE TABLE APP.LINKS(
	src varchar(20) NOT NULL,
	dest varchar(20) NOT NULL,
	weight varchar(20) NOT NULL,
	subnodes varchar(20) NOT NULL,
	src_url varchar(200) NOT NULL,
	dest_url varchar(200) NOT NULL,
	primary key(src, dest)
	--foreign key (src) REFERENCES APP.NODES(id) on delete cascade,
	--foreign key(dest) REFERENCES APP.NODES(id) on delete cascade
);

-- import links.csv to table APP.LINKS
CALL SYSCS_UTIL.SYSCS_IMPORT_TABLE
( 'APP', 'LINKS','data/links.csv',',',null,null,0 );

-- delete column header
DELETE FROM APP.LINKS WHERE src = 'Source';

disconnect;
exit;