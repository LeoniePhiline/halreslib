CREATE TABLE urls (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    url TEXT NOT NULL,
    meetup_date DATE NOT NULL
);

CREATE TABLE scraped (
    url BIGINT PRIMARY KEY REFERENCES urls (id),
    title TEXT CHECK (LENGTH(content) < 1024),
    content TEXT CHECK (LENGTH(content) < 300 * 1024)
);

CREATE TABLE summary (
    url BIGINT PRIMARY KEY REFERENCES urls (id),
    summary TEXT CHECK (LENGTH(summary) < 4096)
);

CREATE TABLE tags (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    url BIGINT REFERENCES urls (id),
    tag TEXT CHECK (LENGTH(tag) < 128)
);

CREATE TABLE authors (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    url BIGINT REFERENCES urls (id),
    author TEXT CHECK (LENGTH(author) < 128)
);
