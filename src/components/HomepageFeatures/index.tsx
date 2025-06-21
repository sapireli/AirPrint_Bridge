import type { ReactNode } from "react";
import clsx from "clsx";
import Heading from "@theme/Heading";
import styles from "./styles.module.css";

type FeatureItem = {
  title: string;
  icon: string;
  description: ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: "🖨️ Universal Printer Support",
    icon: "🖨️",
    description: (
      <>
        Enable AirPrint for <strong>any printer</strong> that can be shared on
        macOS. Works with USB, network, and legacy printers that don't natively
        support AirPrint.
      </>
    ),
  },
  {
    title: "🚀 Zero Configuration",
    icon: "🚀",
    description: (
      <>
        <strong>Automatic detection</strong> of shared printers. No manual setup
        required. iOS devices discover printers instantly without any
        configuration.
      </>
    ),
  },
  {
    title: "🔄 Persistent Service",
    icon: "🔄",
    description: (
      <>
        Runs as a <code>launchd</code> service that starts automatically with
        macOS. Printers remain available even after reboots and system updates.
      </>
    ),
  },
  {
    title: "🛡️ Secure & Private",
    icon: "🛡️",
    description: (
      <>
        <strong>No data leaves your Mac</strong>. Works entirely locally using
        macOS built-in Bonjour and CUPS services. No external dependencies or
        cloud services.
      </>
    ),
  },
  {
    title: "💤 Sleep Proxy Compatible",
    icon: "💤",
    description: (
      <>
        Integrates with macOS Bonjour Sleep Proxy. Printers remain discoverable
        even when your Mac is sleeping, providing seamless printing experience.
      </>
    ),
  },
  {
    title: "🔧 Easy Management",
    icon: "🔧",
    description: (
      <>
        Simple <code>install</code>, <code>test</code>, and{" "}
        <code>uninstall</code> commands. Clean removal with no system
        modifications left behind.
      </>
    ),
  },
];

function Feature({ title, icon, description }: FeatureItem) {
  return (
    <div className={clsx("col col--4")}>
      <div className="text--center">
        <div
          className={styles.featureIcon}
          style={{ fontSize: "3rem", marginBottom: "1rem" }}
        >
          {icon}
        </div>
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3" style={{ fontSize: "1.2rem", marginBottom: "1rem" }}>
          {title}
        </Heading>
        <p style={{ lineHeight: "1.6" }}>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section
      className={styles.features}
      style={{
        padding: "4rem 0",
        backgroundColor: "var(--ifm-color-emphasis-100)",
      }}
    >
      <div className="container">
        <div className="text--center" style={{ marginBottom: "3rem" }}>
          <Heading as="h2" style={{ fontSize: "2.5rem", marginBottom: "1rem" }}>
            Why Choose AirPrint Bridge?
          </Heading>
          <p
            style={{
              fontSize: "1.2rem",
              maxWidth: "800px",
              margin: "0 auto",
              color: "var(--ifm-color-emphasis-700)",
            }}
          >
            The most reliable and efficient way to enable AirPrint functionality
            for non-AirPrint printers on macOS
          </p>
        </div>
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
