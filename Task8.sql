------Get userActivity Report----------------------------------
CREATE OR REPLACE PROCEDURE GetUserActivityReport (
    p_user_id   IN  NUMBER,
    p_result    OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_result FOR
        SELECT 
            u.user_id,
            u.username,
            COUNT(DISTINCT p.post_id) AS total_posts,
            COUNT(DISTINCT i.interaction_id) AS total_interactions
        FROM users u
        LEFT JOIN posts p 
            ON u.user_id = p.user_id
        LEFT JOIN interactions i 
            ON p.post_id = i.post_id
        WHERE u.user_id = p_user_id
        GROUP BY u.user_id, u.username;
END;
/

VAR rc REFCURSOR;

EXEC GetUserActivityReport(1, :rc);

PRINT rc;
-------------Count post of users-----------------------------------------------------
CREATE OR REPLACE FUNCTION GetUserPostCount (
    p_user_id IN NUMBER
) 
RETURN NUMBER
IS
    v_post_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_post_count
    FROM posts
    WHERE user_id = p_user_id;

    RETURN v_post_count;
END;
/

SELECT GetUserPostCount(1) AS total_posts FROM dual;
-----------------------get user count interactions-----------------------------
CREATE OR REPLACE FUNCTION GetUserInteractionCount (
    p_user_id IN NUMBER
) 
RETURN NUMBER
IS
    v_interaction_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_interaction_count
    FROM interactions i
    JOIN posts p 
        ON i.post_id = p.post_id
    WHERE p.user_id = p_user_id;

    RETURN v_interaction_count;
END;
/

SELECT GetUserInteractionCount(1) AS total_interactions FROM dual;
--------------------get user last post date----------------------------------
CREATE OR REPLACE FUNCTION GetUserLastPostDate (
    p_user_id IN NUMBER
) 
RETURN DATE
IS
    v_last_post_date DATE;
BEGIN
    SELECT MAX(post_date)
    INTO v_last_post_date
    FROM posts
    WHERE user_id = p_user_id;

    RETURN v_last_post_date;
END;
/

SELECT GetUserLastPostDate(1) AS last_post_date FROM dual;

---------------Get user engagement------------------------------------------
CREATE OR REPLACE PROCEDURE GetUserEngagementLevel (
    p_user_id IN NUMBER,
    p_level   OUT VARCHAR2
)
AS
    v_total_interactions NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total_interactions
    FROM interactions i
    JOIN posts p ON i.post_id = p.post_id
    WHERE p.user_id = p_user_id;

    IF v_total_interactions >= 50 THEN
        p_level := 'High Engagement';
    ELSIF v_total_interactions >= 20 THEN
        p_level := 'Moderate Engagement';
    ELSE
        p_level := 'Low Engagement';
    END IF;
END;
/

VAR lvl VARCHAR2(50);
EXEC GetUserEngagementLevel(1, :lvl);
PRINT lvl;











