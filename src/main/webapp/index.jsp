<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>TA Recruitment - 登录注册</title>
    <style>
        :root {
            --bg-start: #EEF2FF;
            --bg-end: #E0E7FF;
            --ink: #1E293B;
            --muted: #64748B;
            --line: #CBD5E1;
            --white: #FFFFFF;
            --blue: #3B82F6;
            --cyan: #06B6D4;
            --error: #EF4444;
            --success: #10B981;
            --weak: #F97316;
            --medium: #FACC15;
            --strong: #22C55E;
            --radius-xl: 24px;
            --radius-md: 12px;
            --shadow-card: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: "SF Pro Display", "PingFang SC", "Microsoft YaHei", sans-serif;
            color: var(--ink);
            background: linear-gradient(135deg, var(--bg-start), var(--bg-end));
            overflow-x: hidden;
        }

        .bg-orb {
            position: fixed;
            width: 320px;
            height: 320px;
            border-radius: 50%;
            filter: blur(100px);
            opacity: 0.5;
            pointer-events: none;
            z-index: 0;
        }

        .orb-top-left {
            top: -120px;
            left: -90px;
            background: #67E8F9;
        }

        .orb-bottom-right {
            right: -90px;
            bottom: -110px;
            background: #A7F3D0;
        }

        .side-shortcuts {
            position: fixed;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            display: flex;
            flex-direction: column;
            gap: 14px;
            z-index: 2;
        }

        .shortcut-btn {
            width: 40px;
            height: 40px;
            border: 0;
            border-radius: 9999px;
            background: linear-gradient(135deg, #F472B6, #EC4899);
            display: grid;
            place-items: center;
            box-shadow: 0 12px 22px rgba(236, 72, 153, 0.28);
            cursor: pointer;
            transition: transform 0.2s ease;
        }

        .shortcut-btn:hover {
            transform: scale(1.06);
        }

        .shortcut-btn svg {
            width: 18px;
            height: 18px;
            fill: #FFFFFF;
        }

        .page {
            position: relative;
            z-index: 1;
            min-height: 100vh;
            display: grid;
            grid-template-columns: 2fr 3fr;
            align-items: center;
            gap: 28px;
            padding: 36px 40px 36px 84px;
        }

        .brand {
            align-self: stretch;
            display: flex;
            flex-direction: column;
            justify-content: center;
            gap: 16px;
        }

        .brand h1 {
            margin: 0;
            font-size: 42px;
            line-height: 1.08;
            color: var(--ink);
            font-weight: 800;
            letter-spacing: -0.02em;
        }

        .brand .school {
            margin: 0;
            color: var(--muted);
            letter-spacing: 0.24em;
            text-transform: uppercase;
            font-size: 12px;
            font-weight: 600;
        }

        .brand .desc {
            margin: 2px 0 0;
            color: #334155;
            max-width: 420px;
            line-height: 1.7;
            font-size: 16px;
        }

        .feature-pills {
            margin-top: 10px;
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .feature-pills span {
            border: 1px solid #93C5FD;
            color: #1D4ED8;
            background: #FFFFFF;
            border-radius: 9999px;
            padding: 8px 14px;
            font-size: 13px;
            font-weight: 600;
        }

        .auth-wrap {
            display: flex;
            justify-content: center;
            width: 100%;
        }

        .auth-card {
            width: 100%;
            max-width: 480px;
            background: var(--white);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-card);
            padding: 48px;
        }

        .switcher {
            display: grid;
            grid-template-columns: 1fr 1fr;
            background: #E2E8F0;
            padding: 4px;
            border-radius: 9999px;
            margin-bottom: 24px;
        }

        .switcher button {
            border: 0;
            border-radius: 9999px;
            padding: 10px 14px;
            font-size: 14px;
            font-weight: 700;
            color: #475569;
            background: transparent;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .switcher button.active {
            background: var(--blue);
            color: #FFFFFF;
            box-shadow: 0 6px 14px rgba(59, 130, 246, 0.28);
        }

        .view {
            opacity: 0;
            transform: translateY(8px);
            visibility: hidden;
            height: 0;
            overflow: hidden;
            transition: opacity 0.3s ease, transform 0.3s ease;
        }

        .view.active {
            opacity: 1;
            transform: translateY(0);
            visibility: visible;
            height: auto;
            overflow: visible;
        }

        .role-grid-login,
        .role-grid-register {
            display: grid;
            gap: 10px;
            margin-bottom: 16px;
        }

        .role-grid-login {
            grid-template-columns: repeat(3, 1fr);
        }

        .role-grid-register {
            grid-template-columns: repeat(3, 1fr);
        }

        .role-option {
            border: 1px solid #D1D5DB;
            border-radius: 14px;
            padding: 10px 8px;
            background: #F8FAFC;
            text-align: center;
            font-size: 13px;
            font-weight: 700;
            color: #334155;
            cursor: pointer;
            transition: all 0.2s ease;
            user-select: none;
            display: grid;
            place-items: center;
            gap: 4px;
        }

        .role-option svg {
            width: 16px;
            height: 16px;
            fill: #334155;
        }

        .role-option.active {
            border-color: var(--blue);
            background: #EFF6FF;
            box-shadow: 0 10px 16px rgba(59, 130, 246, 0.2);
        }

        .field {
            position: relative;
            margin-bottom: 14px;
        }

        .field input {
            width: 100%;
            border: 1px solid var(--line);
            border-radius: var(--radius-md);
            padding: 14px 14px 14px 44px;
            font-size: 14px;
            background: #FFFFFF;
            outline: none;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .field input.with-right {
            padding-right: 44px;
        }

        .field input:focus {
            border-color: var(--blue);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
        }

        .field.error input {
            border-color: var(--error);
            box-shadow: 0 0 0 2px rgba(239, 68, 68, 0.15);
            animation: shake 0.28s ease;
        }

        .field-icon,
        .field-eye {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            display: grid;
            place-items: center;
            width: 18px;
            height: 18px;
        }

        .field-icon {
            left: 14px;
        }

        .field-eye {
            right: 14px;
            border: 0;
            background: transparent;
            cursor: pointer;
            padding: 0;
        }

        .field-icon svg,
        .field-eye svg {
            width: 18px;
            height: 18px;
            fill: #64748B;
        }

        .error-msg {
            min-height: 18px;
            margin-top: 6px;
            color: var(--error);
            font-size: 12px;
        }

        .hint-msg {
            min-height: 18px;
            margin-top: 6px;
            color: #64748B;
            font-size: 12px;
        }

        .aux-row {
            margin-top: 2px;
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
        }

        .remember {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: #475569;
            font-size: 13px;
        }

        .remember input {
            width: 16px;
            height: 16px;
        }

        .ghost-link {
            border: 0;
            background: none;
            color: #64748B;
            font-size: 12px;
            cursor: pointer;
            text-decoration: none;
            padding: 0;
        }

        .ghost-link:hover {
            color: #334155;
        }

        .submit-btn {
            width: 100%;
            border: 0;
            border-radius: 9999px;
            padding: 13px 16px;
            font-size: 15px;
            font-weight: 700;
            color: #FFFFFF;
            cursor: pointer;
            background: linear-gradient(90deg, #3B82F6, #06B6D4);
            transition: transform 0.18s ease, opacity 0.2s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .submit-btn:hover {
            transform: scale(1.02);
        }

        .submit-btn:disabled {
            opacity: 0.75;
            cursor: not-allowed;
            transform: none;
        }

        .spinner {
            width: 15px;
            height: 15px;
            border: 2px solid rgba(255, 255, 255, 0.45);
            border-top-color: #FFFFFF;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            display: none;
        }

        .submit-btn.loading .spinner {
            display: inline-block;
        }

        .bottom-note {
            margin-top: 14px;
            text-align: center;
            font-size: 13px;
            color: #64748B;
        }

        .bottom-note button {
            border: 0;
            background: transparent;
            color: #1D4ED8;
            cursor: pointer;
            padding: 0;
            font-weight: 700;
        }

        .strength {
            margin-top: 8px;
        }

        .strength-track {
            width: 100%;
            height: 8px;
            border-radius: 9999px;
            background: #E2E8F0;
            overflow: hidden;
        }

        .strength-fill {
            height: 100%;
            width: 0;
            background: var(--weak);
            transition: width 0.2s ease, background-color 0.2s ease;
        }

        .strength-text {
            margin-top: 6px;
            font-size: 12px;
            color: #64748B;
        }

        .toast {
            position: fixed;
            left: 50%;
            transform: translate(-50%, -140%);
            top: 18px;
            padding: 10px 16px;
            border-radius: 9999px;
            background: var(--success);
            color: #FFFFFF;
            font-size: 13px;
            box-shadow: 0 10px 22px rgba(16, 185, 129, 0.28);
            opacity: 0;
            pointer-events: none;
            transition: transform 0.3s ease, opacity 0.3s ease;
            z-index: 5;
        }

        .toast.show {
            transform: translate(-50%, 0);
            opacity: 1;
        }

        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }

        @keyframes shake {
            0% { transform: translateX(0); }
            25% { transform: translateX(-5px); }
            50% { transform: translateX(5px); }
            75% { transform: translateX(-4px); }
            100% { transform: translateX(0); }
        }

        @media (max-width: 768px) {
            .page {
                grid-template-columns: 1fr;
                gap: 18px;
                padding: 20px 16px 24px;
            }

            .side-shortcuts {
                top: auto;
                left: 14px;
                bottom: 12px;
                transform: none;
            }

            .brand {
                border-radius: 20px;
                background: rgba(255, 255, 255, 0.65);
                padding: 20px;
                backdrop-filter: blur(6px);
            }

            .brand h1 {
                font-size: 30px;
            }

            .auth-card {
                padding: 24px 18px;
                border-radius: 20px;
            }

            .role-grid-login,
            .role-grid-register {
                grid-template-columns: 1fr 1fr 1fr;
            }
        }
    </style>
</head>
<body>
<div class="bg-orb orb-top-left"></div>
<div class="bg-orb orb-bottom-right"></div>

<div class="side-shortcuts" aria-hidden="true">
    <button class="shortcut-btn" type="button" title="Jobs">
        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5h16a1 1 0 0 1 1 1v3H3V6a1 1 0 0 1 1-1Zm17 6v7a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1v-7h6v1a1 1 0 1 0 2 0v-1h2v1a1 1 0 1 0 2 0v-1h6Z"/></svg>
    </button>
    <button class="shortcut-btn" type="button" title="Support">
        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2a8 8 0 0 0-8 8v1a2 2 0 0 0-2 2v2a2 2 0 0 0 2 2h2v-6a6 6 0 1 1 12 0v7h-4a1 1 0 0 0 0 2h4a2 2 0 0 0 2-2v-5a2 2 0 0 0-2-2v-1a8 8 0 0 0-8-8Z"/></svg>
    </button>
</div>

<div id="toast" class="toast" role="status" aria-live="polite">操作成功</div>

<main class="page">
    <section class="brand">
        <h1>TA Recruitment System</h1>
        <p class="school">BUPT INTERNATIONAL SCHOOL</p>
        <p class="desc">iPhone-inspired interface, stable text-file backend, agile delivery.</p>
        <div class="feature-pills">
            <span>Browse Jobs</span>
            <span>MO Console</span>
            <span>Admin Workload</span>
        </div>
    </section>

    <section class="auth-wrap">
        <div class="auth-card">
            <div class="switcher" role="tablist" aria-label="登录注册切换">
                <button id="tabLogin" class="active" type="button" role="tab" aria-selected="true">登录</button>
                <button id="tabRegister" type="button" role="tab" aria-selected="false">注册</button>
            </div>

            <div id="loginView" class="view active">
                <form id="loginForm" novalidate>
                    <%-- 表单提交至LoginServlet --%>
                    <input type="hidden" name="role" id="loginRole" value=""/>
                    <div class="role-grid-login" aria-label="登录角色选择">
                        <button class="role-option" data-role-login="TA" type="button">TA</button>
                        <button class="role-option" data-role-login="MO" type="button">MO</button>
                        <button class="role-option" data-role-login="ADMIN" type="button">Admin</button>
                    </div>

                    <div class="field" id="loginEmailField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M3 6a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v1.2l-9 5.63a1.9 1.9 0 0 1-2 0L3 7.2V6Zm0 3.56V18a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V9.56l-7.94 4.97a3.9 3.9 0 0 1-4.12 0L3 9.56Z"/></svg>
                        </span>
                        <input id="loginIdentifier" name="identifier" type="text" placeholder="先选择身份" required/>
                        <div class="hint-msg" id="loginCredentialHint">TA: 学号/邮箱, MO: 教工号/邮箱, Admin: 管理员账号</div>
                        <div class="error-msg" id="loginEmailError"></div>
                    </div>

                    <div class="field" id="loginPasswordField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M17 9h-1V7a4 4 0 1 0-8 0v2H7a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-8a2 2 0 0 0-2-2Zm-7-2a2 2 0 1 1 4 0v2h-4V7Zm3 7.73V17a1 1 0 1 1-2 0v-2.27a2 2 0 1 1 2 0Z"/></svg>
                        </span>
                        <input id="loginPassword" class="with-right" name="password" type="password" placeholder="密码" required/>
                        <button class="field-eye" type="button" data-toggle-eye="loginPassword" aria-label="显示或隐藏密码">
                            <svg viewBox="0 0 24 24"><path d="M12 5c5.6 0 9.5 4.57 10.76 6.24a1.2 1.2 0 0 1 0 1.52C21.5 14.43 17.6 19 12 19S2.5 14.43 1.24 12.76a1.2 1.2 0 0 1 0-1.52C2.5 9.57 6.4 5 12 5Zm0 3a4 4 0 1 0 0 8 4 4 0 0 0 0-8Z"/></svg>
                        </button>
                        <div class="error-msg" id="loginPasswordError"></div>
                    </div>

                    <div class="aux-row">
                        <label class="remember"><input type="checkbox" id="rememberMe" name="rememberMe"/> 记住我</label>
                        <a class="ghost-link" href="#">忘记密码？</a>
                    </div>

                    <button id="loginBtn" class="submit-btn" type="submit">
                        <span class="spinner" aria-hidden="true"></span>
                        <span>登录</span>
                    </button>
                </form>
            </div>

            <div id="registerView" class="view">
                <form id="registerForm" novalidate>
                    <%-- 表单提交至RegisterServlet --%>
                    <input type="hidden" id="registerRole" name="role" value="TA"/>

                    <div class="field" id="nameField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M12 12a5 5 0 1 0-5-5 5 5 0 0 0 5 5Zm0 2c-4.08 0-8 2.04-8 5v1a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1v-1c0-2.96-3.92-5-8-5Z"/></svg>
                        </span>
                        <input id="registerName" name="name" type="text" placeholder="姓名" required/>
                        <div class="error-msg" id="nameError"></div>
                    </div>

                    <div class="field" id="registerIdentifierField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M19 4H5a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2Zm0 2v2.2l-7 4.38-7-4.38V6h14Zm0 12H5V10.56l6.47 4.03a1 1 0 0 0 1.06 0L19 10.56V18Z"/></svg>
                        </span>
                        <input id="registerIdentifier" name="identifier" type="text" placeholder="学号/教工号/管理员账号" required/>
                        <div class="hint-msg" id="registerIdentifierHint">根据角色输入凭证：TA 学号/邮箱，MO 教工号/邮箱，Admin 账号</div>
                        <div class="error-msg" id="registerIdentifierError"></div>
                    </div>

                    <div class="field" id="registerEmailField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M3 6a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v1.2l-9 5.63a1.9 1.9 0 0 1-2 0L3 7.2V6Zm0 3.56V18a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V9.56l-7.94 4.97a3.9 3.9 0 0 1-4.12 0L3 9.56Z"/></svg>
                        </span>
                        <input id="registerEmail" name="email" type="email" placeholder="邮箱" required/>
                        <div class="hint-msg" id="registerEmailHint">请输入有效邮箱格式，如 name@example.com</div>
                        <div class="error-msg" id="registerEmailError"></div>
                    </div>

                    <div class="field" id="registerPasswordField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M17 9h-1V7a4 4 0 1 0-8 0v2H7a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-8a2 2 0 0 0-2-2Zm-7-2a2 2 0 1 1 4 0v2h-4V7Zm3 7.73V17a1 1 0 1 1-2 0v-2.27a2 2 0 1 1 2 0Z"/></svg>
                        </span>
                        <input id="registerPassword" class="with-right" name="password" type="password" placeholder="密码" required/>
                        <button class="field-eye" type="button" data-toggle-eye="registerPassword" aria-label="显示或隐藏密码">
                            <svg viewBox="0 0 24 24"><path d="M12 5c5.6 0 9.5 4.57 10.76 6.24a1.2 1.2 0 0 1 0 1.52C21.5 14.43 17.6 19 12 19S2.5 14.43 1.24 12.76a1.2 1.2 0 0 1 0-1.52C2.5 9.57 6.4 5 12 5Zm0 3a4 4 0 1 0 0 8 4 4 0 0 0 0-8Z"/></svg>
                        </button>
                        <div class="strength">
                            <div class="strength-track"><div id="strengthFill" class="strength-fill"></div></div>
                            <div id="strengthText" class="strength-text">密码强度：弱</div>
                        </div>
                        <div class="error-msg" id="registerPasswordError"></div>
                    </div>

                    <div class="field" id="confirmPasswordField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M17 9h-1V7a4 4 0 1 0-8 0v2H7a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-8a2 2 0 0 0-2-2Zm-7-2a2 2 0 1 1 4 0v2h-4V7Zm3 7.73V17a1 1 0 1 1-2 0v-2.27a2 2 0 1 1 2 0Z"/></svg>
                        </span>
                        <input id="confirmPassword" class="with-right" name="confirmPassword" type="password" placeholder="确认密码" required/>
                        <button class="field-eye" type="button" data-toggle-eye="confirmPassword" aria-label="显示或隐藏密码">
                            <svg viewBox="0 0 24 24"><path d="M12 5c5.6 0 9.5 4.57 10.76 6.24a1.2 1.2 0 0 1 0 1.52C21.5 14.43 17.6 19 12 19S2.5 14.43 1.24 12.76a1.2 1.2 0 0 1 0-1.52C2.5 9.57 6.4 5 12 5Zm0 3a4 4 0 1 0 0 8 4 4 0 0 0 0-8Z"/></svg>
                        </button>
                        <div class="error-msg" id="confirmPasswordError"></div>
                    </div>

                    <div class="role-grid-register" aria-label="注册角色选择">
                        <button class="role-option active" type="button" data-role-register="TA">
                            <svg viewBox="0 0 24 24"><path d="M12 12a5 5 0 1 0-5-5 5 5 0 0 0 5 5Zm0 2c-4.08 0-8 2.04-8 5v1a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1v-1c0-2.96-3.92-5-8-5Z"/></svg>
                            TA
                        </button>
                        <button class="role-option" type="button" data-role-register="MO">
                            <svg viewBox="0 0 24 24"><path d="M12 3 2 8l10 5 8.2-4.1V15h2V8L12 3Zm-7 9v4l7 4 7-4v-4l-7 3.5L5 12Z"/></svg>
                            MO
                        </button>
                        <button class="role-option" type="button" data-role-register="ADMIN">
                            <svg viewBox="0 0 24 24"><path d="M12 2 4 6v6c0 5 3.4 9.7 8 11 4.6-1.3 8-6 8-11V6l-8-4Zm0 2.2 6 3v4.8c0 4-2.6 7.9-6 9-3.4-1.1-6-5-6-9V7.2l6-3Z"/></svg>
                            Admin
                        </button>
                    </div>

                    <button id="registerBtn" class="submit-btn" type="submit">
                        <span class="spinner" aria-hidden="true"></span>
                        <span>创建账户</span>
                    </button>

                    <div class="bottom-note">
                        已有账户？<button id="toLoginLink" type="button">立即登录</button>
                    </div>
                </form>
            </div>
        </div>
    </section>
</main>

<script>
    (function () {
        var tabLogin = document.getElementById("tabLogin");
        var tabRegister = document.getElementById("tabRegister");
        var loginView = document.getElementById("loginView");
        var registerView = document.getElementById("registerView");
        var toLoginLink = document.getElementById("toLoginLink");
        var toast = document.getElementById("toast");

        var loginForm = document.getElementById("loginForm");
        var registerForm = document.getElementById("registerForm");
        var loginBtn = document.getElementById("loginBtn");
        var registerBtn = document.getElementById("registerBtn");

        var loginRole = document.getElementById("loginRole");
        var registerRole = document.getElementById("registerRole");

        var registerPassword = document.getElementById("registerPassword");
        var confirmPassword = document.getElementById("confirmPassword");
        var strengthFill = document.getElementById("strengthFill");
        var strengthText = document.getElementById("strengthText");

        function switchView(target) {
            var isLogin = target === "login";
            tabLogin.classList.toggle("active", isLogin);
            tabRegister.classList.toggle("active", !isLogin);
            tabLogin.setAttribute("aria-selected", String(isLogin));
            tabRegister.setAttribute("aria-selected", String(!isLogin));
            loginView.classList.toggle("active", isLogin);
            registerView.classList.toggle("active", !isLogin);
        }

        tabLogin.addEventListener("click", function () { switchView("login"); });
        tabRegister.addEventListener("click", function () { switchView("register"); });
        toLoginLink.addEventListener("click", function () { switchView("login"); });

        document.querySelectorAll("[data-role-login]").forEach(function (btn) {
            btn.addEventListener("click", function () {
                document.querySelectorAll("[data-role-login]").forEach(function (el) { el.classList.remove("active"); });
                btn.classList.add("active");
                loginRole.value = btn.getAttribute("data-role-login");
                updateLoginIdentifierUi(loginRole.value);
                validateLogin();
            });
        });

        document.querySelectorAll("[data-role-register]").forEach(function (btn) {
            btn.addEventListener("click", function () {
                document.querySelectorAll("[data-role-register]").forEach(function (el) { el.classList.remove("active"); });
                btn.classList.add("active");
                registerRole.value = btn.getAttribute("data-role-register");
                updateRegisterIdentifierUi(registerRole.value);
                validateRegister();
            });
        });

        document.querySelectorAll("[data-toggle-eye]").forEach(function (eyeBtn) {
            eyeBtn.addEventListener("click", function () {
                var targetId = eyeBtn.getAttribute("data-toggle-eye");
                var input = document.getElementById(targetId);
                input.type = input.type === "password" ? "text" : "password";
            });
        });

        function isEmailValid(email) {
            return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
        }

        function updateLoginIdentifierUi(role) {
            var input = document.getElementById("loginIdentifier");
            var hint = document.getElementById("loginCredentialHint");
            if (!role) {
                input.placeholder = "先选择身份";
                hint.textContent = "TA: 学号/邮箱, MO: 教工号/邮箱, Admin: 管理员账号";
                return;
            }
            if (role === "TA") {
                input.placeholder = "学号或邮箱";
                hint.textContent = "示例: 2023213149 或 1171629723@qq.com";
            } else if (role === "MO") {
                input.placeholder = "教工号或邮箱";
                hint.textContent = "示例: TCH1001 或 mo001@bupt.edu.cn";
            } else {
                input.placeholder = "管理员账号";
                hint.textContent = "示例: admin";
            }
        }

        function updateRegisterIdentifierUi(role) {
            var input = document.getElementById("registerIdentifier");
            var hint = document.getElementById("registerIdentifierHint");
            if (role === "TA") {
                input.placeholder = "学号或邮箱";
                hint.textContent = "示例: 2023213149 或 1171629723@qq.com";
            } else if (role === "MO") {
                input.placeholder = "教工号或邮箱";
                hint.textContent = "示例: TCH1001 或 mo001@bupt.edu.cn";
            } else {
                input.placeholder = "管理员账号";
                hint.textContent = "示例: admin";
            }
        }

        function setFieldError(fieldId, errorId, message) {
            var field = document.getElementById(fieldId);
            var error = document.getElementById(errorId);
            if (message) {
                field.classList.add("error");
                error.textContent = message;
            } else {
                field.classList.remove("error");
                error.textContent = "";
            }
        }

        function evaluateStrength(pwd) {
            var score = 0;
            if (pwd.length >= 8) score += 1;
            if (/[A-Z]/.test(pwd) && /[a-z]/.test(pwd)) score += 1;
            if (/\d/.test(pwd)) score += 1;
            if (/[^A-Za-z0-9]/.test(pwd)) score += 1;
            return score;
        }

        function updateStrength() {
            var score = evaluateStrength(registerPassword.value);
            var width = 25;
            var text = "密码强度：弱";
            var color = "var(--weak)";

            if (score >= 2) {
                width = 55;
                text = "密码强度：中";
                color = "var(--medium)";
            }
            if (score >= 4) {
                width = 100;
                text = "密码强度：强";
                color = "var(--strong)";
            }
            if (!registerPassword.value) {
                width = 0;
                text = "密码强度：弱";
                color = "var(--weak)";
            }

            strengthFill.style.width = width + "%";
            strengthFill.style.background = color;
            strengthText.textContent = text;
        }

        function validateLogin() {
            var role = loginRole.value;
            var identifier = document.getElementById("loginIdentifier").value.trim();
            var pwd = document.getElementById("loginPassword").value;
            var ok = true;

            if (!role) {
                setFieldError("loginEmailField", "loginEmailError", "登录前必须选择角色");
                ok = false;
            } else {
                var identifierOk = false;
                if (role === "TA") {
                    identifierOk = /^\d{10}$/.test(identifier) || isEmailValid(identifier);
                } else if (role === "MO") {
                    identifierOk = /^[A-Za-z]{3}\d{4}$/.test(identifier) || isEmailValid(identifier);
                } else if (role === "ADMIN") {
                    identifierOk = /^[A-Za-z][A-Za-z0-9_]{2,}$/.test(identifier);
                }

                if (!identifierOk) {
                    setFieldError("loginEmailField", "loginEmailError", "凭证格式与所选角色不匹配");
                    ok = false;
                } else {
                    setFieldError("loginEmailField", "loginEmailError", "");
                }
            }

            if (!pwd) {
                setFieldError("loginPasswordField", "loginPasswordError", "请输入密码");
                ok = false;
            } else {
                setFieldError("loginPasswordField", "loginPasswordError", "");
            }
            return ok;
        }

        function validateRegister() {
            var name = document.getElementById("registerName").value.trim();
            var email = document.getElementById("registerEmail").value.trim();
            var identifier = document.getElementById("registerIdentifier").value.trim();
            var role = registerRole.value;
            var pwd = registerPassword.value;
            var confirm = confirmPassword.value;
            var ok = true;

            if (name.length < 2) {
                setFieldError("nameField", "nameError", "姓名至少 2 个字符");
                ok = false;
            } else {
                setFieldError("nameField", "nameError", "");
            }

            if (!isEmailValid(email)) {
                setFieldError("registerEmailField", "registerEmailError", "邮箱格式不正确");
                ok = false;
            } else {
                setFieldError("registerEmailField", "registerEmailError", "");
            }

            var identifierOk = false;
            if (role === "TA") {
                identifierOk = /^\d{10}$/.test(identifier) || isEmailValid(identifier);
            } else if (role === "MO") {
                identifierOk = /^[A-Za-z]{3}\d{4}$/.test(identifier) || isEmailValid(identifier);
            } else if (role === "ADMIN") {
                identifierOk = /^[A-Za-z][A-Za-z0-9_]{2,}$/.test(identifier);
            }

            if (!identifierOk) {
                setFieldError("registerIdentifierField", "registerIdentifierError", "凭证格式与角色不匹配");
                ok = false;
            } else {
                setFieldError("registerIdentifierField", "registerIdentifierError", "");
            }

            if (pwd.length < 8) {
                setFieldError("registerPasswordField", "registerPasswordError", "密码至少 8 位");
                ok = false;
            } else {
                setFieldError("registerPasswordField", "registerPasswordError", "");
            }

            if (!confirm || confirm !== pwd) {
                setFieldError("confirmPasswordField", "confirmPasswordError", "两次输入密码不一致");
                ok = false;
            } else {
                setFieldError("confirmPasswordField", "confirmPasswordError", "");
            }

            return ok;
        }

        function setLoading(button, loading) {
            button.disabled = loading;
            button.classList.toggle("loading", loading);
        }

        function showToast(message) {
            toast.textContent = message;
            toast.classList.add("show");
            window.setTimeout(function () {
                toast.classList.remove("show");
            }, 2200);
        }

        registerPassword.addEventListener("input", updateStrength);
        confirmPassword.addEventListener("input", function () {
            if (confirmPassword.value && confirmPassword.value !== registerPassword.value) {
                setFieldError("confirmPasswordField", "confirmPasswordError", "两次输入密码不一致");
            } else {
                setFieldError("confirmPasswordField", "confirmPasswordError", "");
            }
        });

        ["loginIdentifier", "loginPassword", "registerName", "registerIdentifier", "registerEmail", "registerPassword"].forEach(function (id) {
            var el = document.getElementById(id);
            if (el) {
                el.addEventListener("input", function () {
                    if (id === "loginIdentifier") validateLogin();
                    if (id === "loginPassword") validateLogin();
                    if (id === "registerName" || id === "registerIdentifier" || id === "registerEmail" || id === "registerPassword") validateRegister();
                });
            }
        });

        loginForm.addEventListener("submit", async function (event) {
            event.preventDefault();
            if (!validateLogin()) return;
            setLoading(loginBtn, true);

            var payload = {
                role: loginRole.value,
                identifier: document.getElementById("loginIdentifier").value.trim(),
                password: document.getElementById("loginPassword").value
            };

            try {
                var loginResponse = await fetch("auth/login", {
                    method: "POST",
                    headers: {"Content-Type": "application/json"},
                    body: JSON.stringify(payload)
                });
                var loginResult = await loginResponse.json();
                if (!loginResponse.ok) {
                    setFieldError("loginPasswordField", "loginPasswordError", loginResult.error || "登录失败");
                    return;
                }
                showToast("登录成功，正在跳转...");
                window.setTimeout(function () {
                    window.location.href = loginResult.redirect || "index.jsp";
                }, 420);
            } catch (_) {
                setFieldError("loginPasswordField", "loginPasswordError", "网络异常，请稍后重试");
            } finally {
                setLoading(loginBtn, false);
            }
        });

        registerForm.addEventListener("submit", async function (event) {
            event.preventDefault();
            if (!validateRegister()) return;
            setLoading(registerBtn, true);

            var payload = {
                name: document.getElementById("registerName").value.trim(),
                role: registerRole.value,
                identifier: document.getElementById("registerIdentifier").value.trim(),
                email: document.getElementById("registerEmail").value.trim(),
                password: registerPassword.value
            };

            try {
                var registerResponse = await fetch("auth/register", {
                    method: "POST",
                    headers: {"Content-Type": "application/json"},
                    body: JSON.stringify(payload)
                });
                var registerResult = await registerResponse.json();
                if (!registerResponse.ok) {
                    setFieldError("registerIdentifierField", "registerIdentifierError", registerResult.error || "注册失败");
                    return;
                }
                showToast("账户创建成功");
                switchView("login");
            } catch (_) {
                setFieldError("registerIdentifierField", "registerIdentifierError", "网络异常，请稍后重试");
            } finally {
                setLoading(registerBtn, false);
            }
        });

        updateLoginIdentifierUi("");
        updateRegisterIdentifierUi(registerRole.value);
    })();
</script>
</body>
</html>
