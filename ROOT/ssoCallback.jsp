
<%@ page import="org.springframework.security.core.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.authentication.UsernamePasswordAuthenticationToken" %>
<%@ page import="org.springframework.security.core.Authentication" %>
<%@ page import="org.springframework.security.core.context.SecurityContext" %>
<%@ page import="org.springframework.security.core.userdetails.UserDetails" %>
<%@ page import="org.springframework.security.web.context.HttpSessionSecurityContextRepository" %>
<%@ page contentType="text/html; charset=utf-8" %>
<%@ include file="/xefc/jsp/common/import.jspf" %>
<%
    Log.biz.info("===== SSO CALLBACK START =====");
    Log.biz.info("SSO_ID : " + session.getAttribute("SSO_ID"));

    String uri = "/";

    try {
        Object ssoIdObj = session.getAttribute("SSO_ID");
//        Object ssoIdObj = "testadmin";

        if (ssoIdObj == null || StringUtil.invalid(ssoIdObj.toString())) {
            Log.biz.info("SSO 인증 정보 없음");
            throw new BizError("SSO 인증 정보 없음");
        }

        String empId = ssoIdObj.toString();

        Log.biz.info("SSO empId : " + empId);

        if ("admin".equalsIgnoreCase(empId)) {
            Log.biz.info("관리자 계정 SSO 로그인 차단");
            throw new BizError("관리자 계정 SSO 로그인 차단");
        }

        ICE ice = ICE.getInstance();
        Users users = ice.users();

        User loginUser = users.getLoginUser(empId);

        Log.biz.info("eGene loginUser : " + (loginUser == null ? "null" : loginUser.emp_id));

        if (loginUser == null) {
            Log.biz.info("eGene 사용자 정보 없음 : " + empId);
            throw new BizError("eGene 사용자 정보 없음");
        }

        /*
         * 기존 eGene 인증 정보만 제거
         * SSO Agent 세션은 유지해야 하므로 session.invalidate() 사용 안 함
         */
        session.removeAttribute("egene.user");
        session.removeAttribute("def_cat_cd");
        session.removeAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY);

        org.springframework.security.core.userdetails.User.UserBuilder userBuilder =
                org.springframework.security.core.userdetails.User
                        .withUsername(loginUser.emp_id)
                        .password(loginUser.getPasswd());

        if (loginUser.admin_yn) {
            userBuilder.roles("USER", "ADMIN");
        } else {
            userBuilder.roles("USER");
        }

        UserDetails userDetails = userBuilder.build();

        Authentication authentication =
                new UsernamePasswordAuthenticationToken(
                        userDetails,
                        "",
                        userDetails.getAuthorities()
                );

        SecurityContext securityContext = SecurityContextHolder.getContext();
        securityContext.setAuthentication(authentication);

        session.setAttribute(
                HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY,
                securityContext
        );

        session.setAttribute("egene.user", users.getUser(empId));
        session.setAttribute("def_cat_cd", loginUser.org_id);

        saveLogin(loginUser, empId, session, request);

        String redirectUri = request.getParameter("redirect_uri");
        String http = GlobalConfig.getInstance().getHttpString(request);

        if (StringUtil.valid(redirectUri) &&
                (redirectUri.startsWith(http) ||
                    (redirectUri.startsWith("/") &&
                        !redirectUri.startsWith("//") &&
                        redirectUri.indexOf("://") < 0
                    )
                )
            ) {
            uri = redirectUri;
        } else {
            uri = "/";
        }

    } catch (BizError e) {
        Log.biz.err(e.getMessage());
        uri = "/";
    } catch (Exception e) {
        Log.biz.err(e);
        uri = "/";
    }

    Log.biz.info("SSO CALLBACK REDIRECT : " + uri);
    response.sendRedirect(uri);
%>

<%!
    void saveLogin(User user, String empId, HttpSession session, HttpServletRequest request) {
        String sessionId = session.getId();
        String ip = HttpUtility.remoteAddr(request);

        Data d = new Data();
        d.put("session", sessionId);
        d.put("usr_id", empId);
        d.put("emp_id", user.emp_id);
        d.put("ip", ip);
        d.put("u_sta_cd", "9");
        d.put("c_sta_cd", "1");
        d.put("sta_cd", "EMPSTA010");
        d.put("note", "SSO");

        ICE ice = ICE.getInstance();
        Sqls sqls = ice.sqls();
        sqls.executeArray("Login.Insert", d);
    }
%>