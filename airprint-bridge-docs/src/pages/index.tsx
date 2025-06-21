import type { ReactNode } from "react";
import clsx from "clsx";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import useBaseUrl from "@docusaurus/useBaseUrl";
import Layout from "@theme/Layout";
import HomepageFeatures from "@site/src/components/HomepageFeatures";
import styles from "./index.module.css";

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={clsx("hero", styles.heroBanner)}>
      <div className="container">
        <img
          src={useBaseUrl("/img/logo.svg")}
          alt="AirPrint Bridge Logo"
          style={{ width: 120, height: 120, marginBottom: 24 }}
        />
        <h1
          className="hero__title"
          style={{ fontWeight: 700, fontSize: "2.8rem" }}
        >
          AirPrint Bridge
        </h1>
        <p
          className="hero__subtitle"
          style={{ fontSize: "1.3rem", maxWidth: 600, margin: "0 auto 2rem" }}
        >
          Seamlessly Enable AirPrint for Non-AirPrint Printers on macOS.
          <br />
          Print wirelessly from your iPhone and iPad — no AirPrint printer
          required!
        </p>
        <div className={styles.buttons} style={{ gap: 16 }}>
          <Link
            className="button button--primary button--lg"
            to="/docs/installation"
          >
            Get Started
          </Link>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro"
          >
            Learn More
          </Link>
          <Link
            className="button button--outline button--lg"
            to="https://github.com/sapireli/AirPrint_Bridge"
          >
            GitHub
          </Link>
        </div>
      </div>
    </header>
  );
}

function QuickStartSection() {
  return (
    <section
      style={{
        padding: "4rem 0",
        backgroundColor: "var(--ifm-background-color)",
      }}
    >
      <div className="container">
        <div className="text--center" style={{ marginBottom: "3rem" }}>
          <h2 style={{ fontSize: "2.5rem", marginBottom: "1rem" }}>
            🚀 Quick Start
          </h2>
          <p
            style={{
              fontSize: "1.2rem",
              maxWidth: "800px",
              margin: "0 auto",
              color: "var(--ifm-color-emphasis-700)",
            }}
          >
            Get AirPrint Bridge running in minutes with these simple steps
          </p>
        </div>
        <div className="row">
          <div className="col col--4">
            <div className="text--center" style={{ padding: "2rem" }}>
              <div style={{ fontSize: "3rem", marginBottom: "1rem" }}>1️⃣</div>
              <h3>Share Your Printer</h3>
              <p>
                Enable printer sharing in System Settings &gt; General &gt;
                Sharing
              </p>
            </div>
          </div>
          <div className="col col--4">
            <div className="text--center" style={{ padding: "2rem" }}>
              <div style={{ fontSize: "3rem", marginBottom: "1rem" }}>2️⃣</div>
              <h3>Install AirPrint Bridge</h3>
              <p>Run the installation script and test with your iOS device</p>
            </div>
          </div>
          <div className="col col--4">
            <div className="text--center" style={{ padding: "2rem" }}>
              <div style={{ fontSize: "3rem", marginBottom: "1rem" }}>3️⃣</div>
              <h3>Start Printing</h3>
              <p>
                Your printer now appears as an AirPrint option on iOS devices
              </p>
            </div>
          </div>
        </div>
        <div className="text--center" style={{ marginTop: "2rem" }}>
          <Link
            className="button button--primary button--lg"
            to="/docs/installation"
          >
            View Full Installation Guide
          </Link>
        </div>
      </div>
    </section>
  );
}

function TechnicalHighlights() {
  return (
    <section
      style={{
        padding: "4rem 0",
        backgroundColor: "var(--ifm-color-emphasis-50)",
      }}
    >
      <div className="container">
        <div className="text--center" style={{ marginBottom: "3rem" }}>
          <h2 style={{ fontSize: "2.5rem", marginBottom: "1rem" }}>
            ⚡ Technical Highlights
          </h2>
          <p
            style={{
              fontSize: "1.2rem",
              maxWidth: "800px",
              margin: "0 auto",
              color: "var(--ifm-color-emphasis-700)",
            }}
          >
            Built with modern macOS technologies for maximum reliability and
            performance
          </p>
        </div>
        <div className="row">
          <div className="col col--6">
            <div
              style={{
                padding: "1.5rem",
                backgroundColor: "var(--ifm-background-color)",
                borderRadius: "8px",
                marginBottom: "1rem",
                border: "1px solid var(--ifm-color-emphasis-200)",
              }}
            >
              <h4
                style={{
                  color: "var(--ifm-color-primary)",
                  marginBottom: "0.5rem",
                }}
              >
                🔍 Automatic Detection
              </h4>
              <p>
                Intelligently detects shared printers and generates appropriate
                URF capability strings
              </p>
            </div>
          </div>
          <div className="col col--6">
            <div
              style={{
                padding: "1.5rem",
                backgroundColor: "var(--ifm-background-color)",
                borderRadius: "8px",
                marginBottom: "1rem",
                border: "1px solid var(--ifm-color-emphasis-200)",
              }}
            >
              <h4
                style={{
                  color: "var(--ifm-color-primary)",
                  marginBottom: "0.5rem",
                }}
              >
                🌐 Bonjour Integration
              </h4>
              <p>
                Uses macOS built-in dns-sd for seamless service discovery and
                registration
              </p>
            </div>
          </div>
          <div className="col col--6">
            <div
              style={{
                padding: "1.5rem",
                backgroundColor: "var(--ifm-background-color)",
                borderRadius: "8px",
                marginBottom: "1rem",
                border: "1px solid var(--ifm-color-emphasis-200)",
              }}
            >
              <h4
                style={{
                  color: "var(--ifm-color-primary)",
                  marginBottom: "0.5rem",
                }}
              >
                🔄 Launchd Service
              </h4>
              <p>
                Persistent background service that starts automatically and
                survives reboots
              </p>
            </div>
          </div>
          <div className="col col--6">
            <div
              style={{
                padding: "1.5rem",
                backgroundColor: "var(--ifm-background-color)",
                borderRadius: "8px",
                marginBottom: "1rem",
                border: "1px solid var(--ifm-color-emphasis-200)",
              }}
            >
              <h4
                style={{
                  color: "var(--ifm-color-primary)",
                  marginBottom: "0.5rem",
                }}
              >
                🛡️ Security First
              </h4>
              <p>
                No external dependencies, works entirely locally with macOS
                security features
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function TestimonialsSection() {
  return (
    <section
      style={{
        padding: "4rem 0",
        backgroundColor: "var(--ifm-background-color)",
      }}
    >
      <div className="container">
        <div className="text--center" style={{ marginBottom: "3rem" }}>
          <h2 style={{ fontSize: "2.5rem", marginBottom: "1rem" }}>
            💬 What Users Say
          </h2>
          <p
            style={{
              fontSize: "1.2rem",
              maxWidth: "800px",
              margin: "0 auto",
              color: "var(--ifm-color-emphasis-700)",
            }}
          >
            Join thousands of users who have successfully enabled AirPrint for
            their printers
          </p>
        </div>
        <div className="row">
          <div className="col col--4">
            <div
              style={{
                padding: "2rem",
                backgroundColor: "var(--ifm-color-emphasis-50)",
                borderRadius: "12px",
                height: "100%",
                border: "1px solid var(--ifm-color-emphasis-200)",
              }}
            >
              <div style={{ fontSize: "2rem", marginBottom: "1rem" }}>⭐</div>
              <p style={{ fontStyle: "italic", marginBottom: "1rem" }}>
                "Finally got my old HP printer working with my iPhone! Setup was
                incredibly easy and it just works."
              </p>
              <strong>— Home User</strong>
            </div>
          </div>
          <div className="col col--4">
            <div
              style={{
                padding: "2rem",
                backgroundColor: "var(--ifm-color-emphasis-50)",
                borderRadius: "12px",
                height: "100%",
                border: "1px solid var(--ifm-color-emphasis-200)",
              }}
            >
              <div style={{ fontSize: "2rem", marginBottom: "1rem" }}>⭐</div>
              <p style={{ fontStyle: "italic", marginBottom: "1rem" }}>
                "Perfect solution for our small office. All our network printers
                now work with iPads without any additional hardware."
              </p>
              <strong>— Small Business Owner</strong>
            </div>
          </div>
          <div className="col col--4">
            <div
              style={{
                padding: "2rem",
                backgroundColor: "var(--ifm-color-emphasis-50)",
                borderRadius: "12px",
                height: "100%",
                border: "1px solid var(--ifm-color-emphasis-200)",
              }}
            >
              <div style={{ fontSize: "2rem", marginBottom: "1rem" }}>⭐</div>
              <p style={{ fontStyle: "italic", marginBottom: "1rem" }}>
                "As a developer, I love how clean and efficient this solution
                is. No bloat, just pure functionality."
              </p>
              <strong>— Software Developer</strong>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export default function Home(): ReactNode {
  return (
    <Layout
      title="AirPrint Bridge - Seamlessly Enable AirPrint for Non-AirPrint Printers on macOS"
      description="Enable AirPrint for any printer on macOS. Print wirelessly from iPhone and iPad to any shared printer."
    >
      <HomepageHeader />
      <main>
        <QuickStartSection />
        <HomepageFeatures />
        <TechnicalHighlights />
        <TestimonialsSection />
      </main>
    </Layout>
  );
}
