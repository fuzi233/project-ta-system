<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>TA Recruitment - Sign In</title>
    <style>
        :root {
            --bg-start: #ffffff;
            --bg-end: #d9e8ff;
            --ink: #102039;
            --muted: #4c5e7a;
            --line: #c2d6ff;
            --white: #FFFFFF;
            --blue: #1575ff;
            --cyan: #00b7a5;
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
            font-family: "SF Pro Text", "SF Pro Display", "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            color: var(--ink);
            background: radial-gradient(circle at 20% 15%, var(--bg-start) 0%, #eef3ff 45%, var(--bg-end) 100%);
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
            grid-template-columns: minmax(340px, 1.05fr) minmax(460px, 1fr);
            align-items: center;
            gap: 36px;
            width: min(1180px, calc(100% - 2rem));
            margin: 0 auto;
            padding: 36px 28px 36px 72px;
        }

        .brand {
            align-self: stretch;
            display: flex;
            flex-direction: column;
            justify-content: center;
            gap: 16px;
            max-width: 520px;
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
            color: #16315b;
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
            align-items: center;
            width: 100%;
        }

        .auth-card {
            width: 100%;
            max-width: 540px;
            background: var(--white);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-card);
            padding: 44px;
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
            color: var(--muted);
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
            min-height: 66px;
            background: #F8FAFC;
            text-align: center;
            font-size: 13px;
            font-weight: 700;
            color: #16315b;
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
            fill: #16315b;
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
            top: 22px;
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
            color: var(--muted);
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
            color: #16315b;
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
            opacity: 1;
            cursor: not-allowed;
            transform: none;
            background: #d8e1ef;
            color: #7a8aa3;
            box-shadow: none;
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

        @media (max-width: 1120px) {
            .page {
                grid-template-columns: 1fr;
                gap: 20px;
                width: min(860px, calc(100% - 1.5rem));
                padding: 28px 12px 28px 16px;
                min-height: auto;
            }

            .brand,
            .auth-wrap {
                max-width: 100%;
            }

            .auth-card {
                margin: 0 auto;
            }
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
                width: calc(100% - 1rem);
                padding: 16px 8px 20px;
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

            .shortcut-btn {
                width: 36px;
                height: 36px;
            }
        }

        /* ---------- Visual Refresh: Liquid Glass + Artistic Lines ---------- */
        :root {
            --bg-start: #dbe8ff;
            --bg-mid: #cadcff;
            --bg-end: #f4f8ff;
            --ink: #0f172a;
            --muted: #54627b;
            --line: rgba(255, 255, 255, 0.5);
            --white: #ffffff;
            --blue: #3678ff;
            --cyan: #3cb4ff;
            --teal: #58d4cf;
            --glass-strong: rgba(255, 255, 255, 0.62);
            --glass-soft: rgba(255, 255, 255, 0.42);
            --radius-xl: 28px;
            --radius-md: 14px;
            --shadow-card: 0 30px 65px rgba(44, 86, 162, 0.24);
        }

        body {
            position: relative;
            background:
                radial-gradient(140% 120% at -8% 4%, rgba(118, 168, 255, 0.36) 0%, rgba(118, 168, 255, 0) 42%),
                radial-gradient(95% 90% at 110% 18%, rgba(89, 220, 212, 0.32) 0%, rgba(89, 220, 212, 0) 44%),
                linear-gradient(142deg, var(--bg-start) 0%, var(--bg-mid) 48%, var(--bg-end) 100%);
        }

        body::before {
            content: "";
            position: fixed;
            inset: 0;
            pointer-events: none;
            z-index: 0;
            opacity: 0.42;
            background:
                linear-gradient(112deg, rgba(255, 255, 255, 0.65) 0%, rgba(255, 255, 255, 0.06) 36%, rgba(255, 255, 255, 0.42) 100%);
            mix-blend-mode: soft-light;
        }

        .bg-grid {
            position: fixed;
            inset: 0;
            pointer-events: none;
            z-index: 0;
            background-image:
                linear-gradient(rgba(255, 255, 255, 0.3) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, 0.25) 1px, transparent 1px);
            background-size: 68px 68px;
            mask-image: radial-gradient(circle at 50% 38%, #000 20%, transparent 82%);
            opacity: 0.45;
        }

        .bg-wave {
            position: fixed;
            left: -18%;
            right: -18%;
            bottom: -200px;
            height: 420px;
            pointer-events: none;
            z-index: 0;
            background: radial-gradient(64% 84% at 50% 20%, rgba(95, 173, 255, 0.38) 0%, rgba(95, 173, 255, 0) 78%);
            filter: blur(8px);
            transform: rotate(-3deg);
        }

        .trace-line {
            position: fixed;
            pointer-events: none;
            z-index: 0;
            border: 1px solid rgba(255, 255, 255, 0.56);
            border-radius: 999px;
            opacity: 0.7;
            mix-blend-mode: screen;
        }

        .trace-one {
            width: 760px;
            height: 760px;
            right: -300px;
            top: -180px;
            transform: rotate(16deg);
        }

        .trace-two {
            width: 640px;
            height: 640px;
            left: -270px;
            bottom: -240px;
            transform: rotate(-18deg);
        }

        .bg-orb {
            filter: blur(92px);
            opacity: 0.56;
        }

        .page {
            width: min(1220px, calc(100% - 2rem));
            padding: 42px 26px 38px 72px;
            gap: 34px;
        }

        .brand {
            position: relative;
            max-width: 560px;
            padding: 34px 34px 32px;
            border-radius: 32px;
            border: 1px solid rgba(255, 255, 255, 0.52);
            background: linear-gradient(140deg, var(--glass-strong), rgba(255, 255, 255, 0.24));
            backdrop-filter: blur(24px) saturate(130%);
            box-shadow:
                inset 0 1px 0 rgba(255, 255, 255, 0.88),
                0 20px 54px rgba(40, 84, 155, 0.2);
        }

        .brand::after {
            content: "";
            position: absolute;
            inset: 12px;
            border-radius: 24px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            pointer-events: none;
        }

        .brand h1 {
            font-size: clamp(2.3rem, 3.9vw, 3.4rem);
            letter-spacing: -0.03em;
            text-wrap: balance;
            margin-top: 4px;
        }

        .brand .school {
            color: #5e6f8d;
            letter-spacing: 0.22em;
        }

        .brand .desc {
            color: #31456b;
            font-size: 15px;
            line-height: 1.75;
        }

        .feature-pills span {
            background: linear-gradient(130deg, rgba(255, 255, 255, 0.86), rgba(235, 245, 255, 0.82));
            border: 1px solid rgba(118, 151, 214, 0.44);
            color: #27549e;
            letter-spacing: 0.01em;
        }

        .side-shortcuts {
            left: 16px;
            gap: 12px;
        }

        .shortcut-btn {
            width: 42px;
            height: 42px;
            border: 1px solid rgba(255, 255, 255, 0.56);
            background: linear-gradient(135deg, rgba(61, 132, 255, 0.9), rgba(84, 215, 209, 0.9));
            box-shadow:
                inset 0 1px 0 rgba(255, 255, 255, 0.5),
                0 14px 24px rgba(58, 118, 211, 0.34);
        }

        .shortcut-btn:hover {
            transform: translateY(-2px) scale(1.04);
        }

        .auth-wrap {
            position: relative;
        }

        .auth-wrap::before {
            content: "";
            position: absolute;
            inset: -36px -26px;
            border-radius: 46px;
            background: radial-gradient(66% 88% at 50% 50%, rgba(97, 179, 255, 0.34) 0%, rgba(97, 179, 255, 0) 78%);
            filter: blur(12px);
            pointer-events: none;
            z-index: 0;
        }

        .auth-card {
            position: relative;
            z-index: 1;
            max-width: 560px;
            border: 1px solid rgba(255, 255, 255, 0.56);
            background: linear-gradient(148deg, rgba(255, 255, 255, 0.7), rgba(248, 252, 255, 0.44));
            backdrop-filter: blur(26px) saturate(136%);
            box-shadow:
                inset 0 1px 0 rgba(255, 255, 255, 0.86),
                var(--shadow-card);
        }

        .auth-card::before {
            content: "";
            position: absolute;
            inset: 0;
            border-radius: inherit;
            border: 1px solid rgba(255, 255, 255, 0.3);
            pointer-events: none;
        }

        .switcher {
            background: rgba(218, 231, 250, 0.72);
            border: 1px solid rgba(255, 255, 255, 0.58);
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.58);
        }

        .switcher button {
            color: #54637f;
        }

        .switcher button.active {
            background: linear-gradient(103deg, #2f6fff, #4ea2ff 56%, #58d4cf);
            box-shadow:
                inset 0 1px 0 rgba(255, 255, 255, 0.5),
                0 12px 20px rgba(61, 121, 221, 0.28);
        }

        .role-option {
            border-color: rgba(160, 183, 224, 0.6);
            background: linear-gradient(152deg, rgba(255, 255, 255, 0.76), rgba(239, 247, 255, 0.52));
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.8);
            min-height: 70px;
        }

        .role-option.active {
            border-color: rgba(57, 119, 255, 0.7);
            background: linear-gradient(146deg, rgba(238, 246, 255, 0.96), rgba(213, 233, 255, 0.86));
            box-shadow:
                inset 0 1px 0 rgba(255, 255, 255, 0.88),
                0 12px 20px rgba(59, 129, 246, 0.25);
        }

        .field input {
            border: 1px solid rgba(157, 185, 228, 0.65);
            background: linear-gradient(150deg, rgba(255, 255, 255, 0.84), rgba(243, 250, 255, 0.72));
            color: #1e2e49;
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.72);
        }

        .field input::placeholder {
            color: #8897af;
        }

        .field input:focus {
            border-color: rgba(54, 122, 255, 0.8);
            box-shadow:
                0 0 0 4px rgba(54, 122, 255, 0.15),
                inset 0 1px 0 rgba(255, 255, 255, 0.75);
        }

        .submit-btn {
            position: relative;
            overflow: hidden;
            background: linear-gradient(98deg, #2f6eff, #4a98ff 52%, #53d4d2);
            box-shadow:
                inset 0 1px 0 rgba(255, 255, 255, 0.42),
                0 16px 28px rgba(54, 116, 210, 0.34);
        }

        .submit-btn::after {
            content: "";
            position: absolute;
            left: -42%;
            top: 0;
            width: 34%;
            height: 100%;
            background: linear-gradient(110deg, transparent 0%, rgba(255, 255, 255, 0.38) 50%, transparent 100%);
            transform: skewX(-18deg);
            transition: left 0.45s ease;
        }

        .submit-btn:hover::after {
            left: 112%;
        }

        .submit-btn:hover {
            transform: translateY(-1px);
            filter: saturate(1.08);
        }

        .toast {
            background: linear-gradient(95deg, #2f6fff, #56c9f3);
            box-shadow: 0 14px 26px rgba(56, 126, 225, 0.32);
        }

        @media (max-width: 1120px) {
            .page {
                width: min(900px, calc(100% - 1.2rem));
                padding: 28px 10px 28px 16px;
            }

            .brand {
                padding: 26px 24px 24px;
            }

            .auth-card {
                max-width: 640px;
            }
        }

        @media (max-width: 768px) {
            .bg-grid {
                opacity: 0.22;
            }

            .bg-wave {
                height: 300px;
                bottom: -150px;
            }

            .trace-line {
                display: none;
            }

            .brand {
                background: linear-gradient(142deg, rgba(255, 255, 255, 0.76), rgba(241, 248, 255, 0.56));
                backdrop-filter: blur(16px) saturate(125%);
                padding: 22px 18px 20px;
                border-radius: 22px;
            }

            .auth-card {
                padding: 24px 16px;
            }
        }

        /* ---------- Single Card Layout + BUPT logo ---------- */
        .site-logo {
            position: fixed;
            left: 18px;
            top: 14px;
            z-index: 4;
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 7px 12px 7px 8px;
            border-radius: 14px;
            background: rgba(255, 255, 255, 0.54);
            border: 1px solid rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(14px) saturate(128%);
            box-shadow: 0 12px 26px rgba(47, 106, 188, 0.24);
        }

        .site-logo .logo-badge {
            width: 54px;
            height: 54px;
            border-radius: 14px;
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, 0.75);
            box-shadow: 0 6px 16px rgba(31, 76, 149, 0.25);
            background: #f8fbff;
        }

        .site-logo .logo-badge img {
            width: 100%;
            height: 100%;
            display: block;
            object-fit: cover;
            object-position: 50% 21%;
        }

        .site-logo .site-logo-text {
            display: flex;
            flex-direction: column;
            line-height: 1.12;
        }

        .site-logo .site-logo-text strong {
            color: #21457f;
            font-size: 12px;
            font-weight: 800;
        }

        .site-logo .site-logo-text span {
            color: #5a6f91;
            font-size: 10px;
            letter-spacing: 0.04em;
            text-transform: uppercase;
        }

        .page {
            grid-template-columns: 1fr;
            width: min(1040px, calc(100% - 1.4rem));
            min-height: 100vh;
            padding: 92px 10px 30px;
            gap: 0;
        }

        .auth-wrap {
            width: 100%;
            justify-content: center;
        }

        .auth-card.auth-card-unified {
            max-width: 900px;
            width: min(900px, 100%);
            padding: 0;
            overflow: hidden;
            display: grid;
            grid-template-columns: minmax(220px, 0.75fr) minmax(0, 1.35fr);
            border-radius: 30px;
        }

        .brand-pane {
            padding: 30px 24px;
            background: linear-gradient(160deg, rgba(225, 242, 255, 0.8), rgba(243, 250, 255, 0.54));
            border-right: 1px solid rgba(255, 255, 255, 0.7);
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            gap: 10px;
        }

        .brand-pane .kicker {
            margin: 0;
            font-size: 11px;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            color: #5d739a;
            font-weight: 700;
        }

        .brand-pane .brand-title {
            margin: 0;
            font-size: 26px;
            font-weight: 800;
            color: #203a69;
            line-height: 1.12;
            letter-spacing: -0.02em;
        }

        .brand-pane .brand-sub {
            margin: 0;
            color: #355384;
            font-size: 13px;
            line-height: 1.62;
        }

        .entry-grid {
            margin-top: 4px;
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 12px;
        }

        .entry-btn {
            width: 100%;
            border: 1px solid rgba(152, 179, 221, 0.7);
            border-radius: 14px;
            background: rgba(255, 255, 255, 0.72);
            color: #2a4675;
            font-size: 14px;
            font-weight: 800;
            padding: 12px 12px;
            cursor: pointer;
            transition: all 0.2s ease;
            text-align: left;
            display: grid;
            gap: 6px;
        }

        .entry-btn span {
            font-size: 12px;
            font-weight: 600;
            color: #51668a;
        }

        .entry-btn:hover {
            border-color: rgba(57, 119, 255, 0.8);
        }

        .entry-btn.active {
            border-color: rgba(57, 119, 255, 0.88);
            color: #0f2e5e;
            background: linear-gradient(138deg, rgba(229, 240, 255, 0.95), rgba(210, 229, 255, 0.82));
            box-shadow:
                inset 0 1px 0 rgba(255, 255, 255, 0.86),
                0 8px 18px rgba(56, 118, 214, 0.2);
        }

        .demo-strip {
            margin-top: 14px;
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            align-items: center;
        }

        .demo-label {
            font-size: 12px;
            font-weight: 700;
            color: #5b6c89;
        }

        .demo-btn {
            border: 1px dashed rgba(57, 119, 255, 0.45);
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.68);
            color: #1a3f7a;
            font-size: 12px;
            font-weight: 700;
            padding: 6px 12px;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .demo-btn:hover {
            border-color: rgba(57, 119, 255, 0.85);
        }

        .form-title {
            margin: 0 0 16px;
            font-size: 20px;
            font-weight: 800;
            color: #203a69;
        }

        .role-pill-group {
            margin: 10px 0 16px;
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .role-pill {
            border: 1px solid rgba(57, 119, 255, 0.35);
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.74);
            color: #1a396c;
            font-size: 12px;
            font-weight: 700;
            padding: 8px 14px;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .role-pill.active {
            border-color: rgba(57, 119, 255, 0.85);
            color: #0f2e5e;
            background: rgba(255, 255, 255, 0.96);
            box-shadow:
                inset 0 1px 0 rgba(255, 255, 255, 0.86),
                0 8px 18px rgba(56, 118, 214, 0.2);
        }

        .form-pane {
            padding: 34px 36px;
            background: linear-gradient(155deg, rgba(255, 255, 255, 0.56), rgba(248, 252, 255, 0.38));
        }

        .form-pane .switcher {
            margin-bottom: 20px;
        }

        .brand {
            display: none;
        }

        @media (max-width: 920px) {
            .auth-card.auth-card-unified {
                grid-template-columns: 1fr;
            }

            .brand-pane {
                border-right: 0;
                border-bottom: 1px solid rgba(255, 255, 255, 0.72);
                padding: 22px 20px;
                gap: 12px;
            }

            .brand-pane .brand-title {
                font-size: 24px;
            }

            .form-pane {
                padding: 24px 20px;
            }
        }

        @media (max-width: 768px) {
            .entry-grid {
                grid-template-columns: 1fr;
            }

            .site-logo {
                left: 10px;
                top: 8px;
                padding: 6px 9px 6px 6px;
                gap: 6px;
            }

            .site-logo .logo-badge {
                width: 44px;
                height: 44px;
            }

            .site-logo .site-logo-text strong {
                font-size: 10px;
            }

            .site-logo .site-logo-text span {
                font-size: 9px;
                letter-spacing: 0.02em;
            }

            .page {
                width: calc(100% - 0.6rem);
                padding-top: 76px;
            }
        }

        .side-shortcuts {
            display: none;
        }

        .role-grid-login,
        .role-grid-register {
            display: none;
        }

        .bg-grid,
        .bg-wave,
        .trace-line {
            display: none;
        }

        body {
            background: linear-gradient(145deg, #dde9ff 0%, #edf4ff 100%);
        }
    </style>
</head>
<body>
<div class="bg-orb orb-top-left"></div>
<div class="bg-orb orb-bottom-right"></div>

<div class="site-logo">
    <span class="logo-badge">
        <img src="assets/images/bupt-is-logo.jpg" alt="BUPT International School Logo"/>
    </span>
    <div class="site-logo-text">
        <strong>BUPT International School</strong>
        <span>Teaching Assistant Recruitment</span>
    </div>
</div>

<div id="toast" class="toast" role="status" aria-live="polite">Action completed</div>

<main class="page">
    <section class="auth-wrap">
        <div class="auth-card auth-card-unified">
            <aside class="brand-pane">
                <p class="kicker">BUPT International School</p>
                <p class="brand-title">TA Recruitment</p>
                <p class="brand-sub">Choose a workspace entry and sign in to continue.</p>
                <p class="brand-sub">Demos are ready to use without registration.</p>
            </aside>
            <div class="form-pane">
            <h2 id="formTitle" class="form-title">Sign in</h2>

            <div id="loginView" class="view active">
                <div class="entry-grid" aria-label="Workspace entry">
                    <button type="button" class="entry-btn active" data-entry-role="TA">
                        TA Login
                        <span>Apply and track your applications</span>
                    </button>
                    <button type="button" class="entry-btn" data-entry-role="MO">
                        MO Login
                        <span>Post jobs and screen candidates</span>
                    </button>
                    <button type="button" class="entry-btn" data-entry-role="ADMIN">
                        Admin / HR Login
                        <span>Workload and allocation oversight</span>
                    </button>
                </div>
                <div class="demo-strip" aria-label="Demo quick fill">
                    <span class="demo-label">Demo quick fill:</span>
                    <button type="button" class="demo-btn" data-demo-role="TA" data-demo-identifier="ta001@bupt.edu.cn" data-demo-password="TaDemo@123">TA Demo</button>
                    <button type="button" class="demo-btn" data-demo-role="MO" data-demo-identifier="mo001@bupt.edu.cn" data-demo-password="MoDemo@123">MO Demo</button>
                    <button type="button" class="demo-btn" data-demo-role="ADMIN" data-demo-identifier="hradmin" data-demo-password="HrDemo@123">Admin / HR Demo</button>
                </div>
                <form id="loginForm" novalidate>
                    <%-- Form submits to LoginServlet --%>
                    <input type="hidden" name="role" id="loginRole" value=""/>
                    <div class="field" id="loginEmailField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M3 6a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v1.2l-9 5.63a1.9 1.9 0 0 1-2 0L3 7.2V6Zm0 3.56V18a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V9.56l-7.94 4.97a3.9 3.9 0 0 1-4.12 0L3 9.56Z"/></svg>
                        </span>
                        <input id="loginIdentifier" name="identifier" type="text" placeholder="Select a role first" required/>
                        <div class="hint-msg" id="loginCredentialHint">TA: student ID/email, MO: staff ID/email, Admin: admin username</div>
                        <div class="error-msg" id="loginEmailError"></div>
                    </div>

                    <div class="field" id="loginPasswordField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M17 9h-1V7a4 4 0 1 0-8 0v2H7a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-8a2 2 0 0 0-2-2Zm-7-2a2 2 0 1 1 4 0v2h-4V7Zm3 7.73V17a1 1 0 1 1-2 0v-2.27a2 2 0 1 1 2 0Z"/></svg>
                        </span>
                        <input id="loginPassword" class="with-right" name="password" type="password" placeholder="Password" required/>
                        <button class="field-eye" type="button" data-toggle-eye="loginPassword" aria-label="Show or hide password">
                            <svg viewBox="0 0 24 24"><path d="M12 5c5.6 0 9.5 4.57 10.76 6.24a1.2 1.2 0 0 1 0 1.52C21.5 14.43 17.6 19 12 19S2.5 14.43 1.24 12.76a1.2 1.2 0 0 1 0-1.52C2.5 9.57 6.4 5 12 5Zm0 3a4 4 0 1 0 0 8 4 4 0 0 0 0-8Z"/></svg>
                        </button>
                        <div class="error-msg" id="loginPasswordError"></div>
                    </div>

                    <div class="aux-row">
                        <label class="remember"><input type="checkbox" id="rememberMe" name="rememberMe"/> Remember me</label>
                        <a class="ghost-link" href="#">Forgot password?</a>
                    </div>

                    <button id="loginBtn" class="submit-btn" type="submit">
                        <span class="spinner" aria-hidden="true"></span>
                        <span>Sign in</span>
                    </button>
                    <div class="bottom-note">
                        Need an account? <button id="toRegisterLink" type="button">Create account</button>
                    </div>
                </form>
            </div>

            <div id="registerView" class="view">
                <form id="registerForm" novalidate>
                    <%-- Form submits to RegisterServlet --%>
                    <input type="hidden" id="registerRole" name="role" value="TA"/>

                    <div class="role-pill-group" aria-label="Register role">
                        <button class="role-pill active" type="button" data-role-register="TA">TA</button>
                        <button class="role-pill" type="button" data-role-register="MO">MO</button>
                        <button class="role-pill" type="button" data-role-register="ADMIN">Admin / HR</button>
                    </div>

                    <div class="field" id="nameField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M12 12a5 5 0 1 0-5-5 5 5 0 0 0 5 5Zm0 2c-4.08 0-8 2.04-8 5v1a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1v-1c0-2.96-3.92-5-8-5Z"/></svg>
                        </span>
                        <input id="registerName" name="name" type="text" placeholder="Full name" required/>
                        <div class="error-msg" id="nameError"></div>
                    </div>

                    <div class="field" id="registerIdentifierField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M19 4H5a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2Zm0 2v2.2l-7 4.38-7-4.38V6h14Zm0 12H5V10.56l6.47 4.03a1 1 0 0 0 1.06 0L19 10.56V18Z"/></svg>
                        </span>
                        <input id="registerIdentifier" name="identifier" type="text" placeholder="Student ID / Staff ID / Admin username" required/>
                        <div class="hint-msg" id="registerIdentifierHint">Enter the identifier for your selected role.</div>
                        <div class="error-msg" id="registerIdentifierError"></div>
                    </div>

                    <div class="field" id="registerEmailField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M3 6a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v1.2l-9 5.63a1.9 1.9 0 0 1-2 0L3 7.2V6Zm0 3.56V18a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V9.56l-7.94 4.97a3.9 3.9 0 0 1-4.12 0L3 9.56Z"/></svg>
                        </span>
                        <input id="registerEmail" name="email" type="email" placeholder="Email address" required/>
                        <div class="hint-msg" id="registerEmailHint">Use a valid email format, e.g. name@example.com</div>
                        <div class="error-msg" id="registerEmailError"></div>
                    </div>

                    <div class="field" id="registerPasswordField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M17 9h-1V7a4 4 0 1 0-8 0v2H7a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-8a2 2 0 0 0-2-2Zm-7-2a2 2 0 1 1 4 0v2h-4V7Zm3 7.73V17a1 1 0 1 1-2 0v-2.27a2 2 0 1 1 2 0Z"/></svg>
                        </span>
                        <input id="registerPassword" class="with-right" name="password" type="password" placeholder="Password" required/>
                        <button class="field-eye" type="button" data-toggle-eye="registerPassword" aria-label="Show or hide password">
                            <svg viewBox="0 0 24 24"><path d="M12 5c5.6 0 9.5 4.57 10.76 6.24a1.2 1.2 0 0 1 0 1.52C21.5 14.43 17.6 19 12 19S2.5 14.43 1.24 12.76a1.2 1.2 0 0 1 0-1.52C2.5 9.57 6.4 5 12 5Zm0 3a4 4 0 1 0 0 8 4 4 0 0 0 0-8Z"/></svg>
                        </button>
                        <div class="strength">
                            <div class="strength-track"><div id="strengthFill" class="strength-fill"></div></div>
                            <div id="strengthText" class="strength-text">Password strength: weak</div>
                        </div>
                        <div class="error-msg" id="registerPasswordError"></div>
                    </div>

                    <div class="field" id="confirmPasswordField">
                        <span class="field-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M17 9h-1V7a4 4 0 1 0-8 0v2H7a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-8a2 2 0 0 0-2-2Zm-7-2a2 2 0 1 1 4 0v2h-4V7Zm3 7.73V17a1 1 0 1 1-2 0v-2.27a2 2 0 1 1 2 0Z"/></svg>
                        </span>
                        <input id="confirmPassword" class="with-right" name="confirmPassword" type="password" placeholder="Confirm password" required/>
                        <button class="field-eye" type="button" data-toggle-eye="confirmPassword" aria-label="Show or hide password">
                            <svg viewBox="0 0 24 24"><path d="M12 5c5.6 0 9.5 4.57 10.76 6.24a1.2 1.2 0 0 1 0 1.52C21.5 14.43 17.6 19 12 19S2.5 14.43 1.24 12.76a1.2 1.2 0 0 1 0-1.52C2.5 9.57 6.4 5 12 5Zm0 3a4 4 0 1 0 0 8 4 4 0 0 0 0-8Z"/></svg>
                        </button>
                        <div class="error-msg" id="confirmPasswordError"></div>
                    </div>

                    <button id="registerBtn" class="submit-btn" type="submit">
                        <span class="spinner" aria-hidden="true"></span>
                        <span>Create account</span>
                    </button>

                    <div class="bottom-note">
                        Already have an account? <button id="toLoginLink" type="button">Back to sign in</button>
                    </div>
                </form>
            </div>
            </div>
        </div>
    </section>
</main>

<script>
    (function () {
        var loginView = document.getElementById("loginView");
        var registerView = document.getElementById("registerView");
        var formTitle = document.getElementById("formTitle");
        var toRegisterLink = document.getElementById("toRegisterLink");
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
        var entryButtons = document.querySelectorAll("[data-entry-role]");
        var demoButtons = document.querySelectorAll("[data-demo-role]");

        function switchView(target) {
            var isLogin = target === "login";
            loginView.classList.toggle("active", isLogin);
            registerView.classList.toggle("active", !isLogin);
            if (formTitle) {
                formTitle.textContent = isLogin ? "Sign in" : "Create account";
            }
        }

        if (toRegisterLink) {
            toRegisterLink.addEventListener("click", function () { switchView("register"); });
        }
        toLoginLink.addEventListener("click", function () { switchView("login"); });

        document.querySelectorAll("[data-role-register]").forEach(function (btn) {
            btn.addEventListener("click", function () {
                document.querySelectorAll("[data-role-register]").forEach(function (el) { el.classList.remove("active"); });
                btn.classList.add("active");
                registerRole.value = btn.getAttribute("data-role-register");
                updateRegisterIdentifierUi(registerRole.value);
                validateRegister();
            });
        });

        function setRoleButtonState(selector, attrName, role) {
            document.querySelectorAll(selector).forEach(function (btn) {
                btn.classList.toggle("active", btn.getAttribute(attrName) === role);
            });
        }

        function setActiveRole(role) {
            setRoleButtonState("[data-entry-role]", "data-entry-role", role);
            setRoleButtonState("[data-role-register]", "data-role-register", role);
            loginRole.value = role;
            registerRole.value = role;
            updateLoginIdentifierUi(role);
            updateRegisterIdentifierUi(role);
            validateLogin();
            validateRegister();
        }

        entryButtons.forEach(function (btn) {
            btn.addEventListener("click", function () {
                setActiveRole(btn.getAttribute("data-entry-role"));
                switchView("login");
            });
        });

        demoButtons.forEach(function (btn) {
            btn.addEventListener("click", function () {
                var role = btn.getAttribute("data-demo-role");
                var identifier = btn.getAttribute("data-demo-identifier");
                var password = btn.getAttribute("data-demo-password");
                setActiveRole(role);
                document.getElementById("loginIdentifier").value = identifier;
                document.getElementById("loginPassword").value = password;
                validateLogin();
                showToast("Demo credentials filled");
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

        function isBuptEmail(email) {
            return isEmailValid(email) && /@bupt\.edu\.cn$/i.test(email);
        }

        function updateLoginIdentifierUi(role) {
            var input = document.getElementById("loginIdentifier");
            var hint = document.getElementById("loginCredentialHint");
            if (!role) {
                input.placeholder = "Select a role first";
                hint.textContent = "TA: student ID/email, MO: staff ID/email, Admin: admin username";
                return;
            }
            if (role === "TA") {
                input.placeholder = "Student ID or email";
                hint.textContent = "Example: ta001 or ta001@bupt.edu.cn";
            } else if (role === "MO") {
                input.placeholder = "Staff ID or email";
                hint.textContent = "Example: TCH1001 or mo001@bupt.edu.cn";
            } else {
                input.placeholder = "Admin username";
                hint.textContent = "Example: hradmin";
            }
        }

        function updateRegisterIdentifierUi(role) {
            var input = document.getElementById("registerIdentifier");
            var hint = document.getElementById("registerIdentifierHint");
            var emailHint = document.getElementById("registerEmailHint");
            if (role === "TA") {
                input.placeholder = "Student ID or email";
                hint.textContent = "Example: ta001 or ta001@bupt.edu.cn";
                emailHint.textContent = "TA registration email must end with @bupt.edu.cn";
            } else if (role === "MO") {
                input.placeholder = "Staff ID or email";
                hint.textContent = "Example: TCH1001 or mo001@bupt.edu.cn";
                emailHint.textContent = "MO registration email must end with @bupt.edu.cn";
            } else {
                input.placeholder = "Admin username";
                hint.textContent = "Example: hradmin";
                emailHint.textContent = "Use a valid email format, e.g. name@example.com";
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
            var text = "Password strength: weak";
            var color = "var(--weak)";

            if (score >= 2) {
                width = 55;
                text = "Password strength: medium";
                color = "var(--medium)";
            }
            if (score >= 4) {
                width = 100;
                text = "Password strength: strong";
                color = "var(--strong)";
            }
            if (!registerPassword.value) {
                width = 0;
                text = "Password strength: weak";
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
                setFieldError("loginEmailField", "loginEmailError", "Please select a role before signing in.");
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
                    setFieldError("loginEmailField", "loginEmailError", "Identifier format does not match the selected role.");
                    ok = false;
                } else {
                    setFieldError("loginEmailField", "loginEmailError", "");
                }
            }

            if (!pwd) {
                setFieldError("loginPasswordField", "loginPasswordError", "Please enter your password.");
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
                setFieldError("nameField", "nameError", "Name must be at least 2 characters.");
                ok = false;
            } else {
                setFieldError("nameField", "nameError", "");
            }

            if (!isEmailValid(email)) {
                setFieldError("registerEmailField", "registerEmailError", "Please enter a valid email address.");
                ok = false;
            } else if ((role === "TA" || role === "MO") && !isBuptEmail(email)) {
                setFieldError("registerEmailField", "registerEmailError", "TA/MO registration email must end with @bupt.edu.cn.");
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
                setFieldError("registerIdentifierField", "registerIdentifierError", "Identifier format does not match the selected role.");
                ok = false;
            } else {
                setFieldError("registerIdentifierField", "registerIdentifierError", "");
            }

            if (pwd.length < 8) {
                setFieldError("registerPasswordField", "registerPasswordError", "Password must be at least 8 characters.");
                ok = false;
            } else {
                setFieldError("registerPasswordField", "registerPasswordError", "");
            }

            if (!confirm || confirm !== pwd) {
                setFieldError("confirmPasswordField", "confirmPasswordError", "Passwords do not match.");
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
                setFieldError("confirmPasswordField", "confirmPasswordError", "Passwords do not match.");
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
                    setFieldError("loginPasswordField", "loginPasswordError", loginResult.error || "Sign-in failed.");
                    return;
                }
                showToast("Signed in. Redirecting...");
                window.setTimeout(function () {
                    window.location.href = loginResult.redirect || "index.jsp";
                }, 420);
            } catch (_) {
                setFieldError("loginPasswordField", "loginPasswordError", "Network error. Please try again.");
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
                    var errorMessage = registerResult.error || "Registration failed.";
                    if (/email/i.test(errorMessage)) {
                        setFieldError("registerEmailField", "registerEmailError", errorMessage);
                    } else {
                        setFieldError("registerIdentifierField", "registerIdentifierError", errorMessage);
                    }
                    return;
                }
                showToast("Account created.");
                switchView("login");
            } catch (_) {
                setFieldError("registerIdentifierField", "registerIdentifierError", "Network error. Please try again.");
            } finally {
                setLoading(registerBtn, false);
            }
        });

        setActiveRole("TA");
    })();
</script>
</body>
</html>
