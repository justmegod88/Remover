import SwiftUI
import ARKit
import SceneKit

/// Wraps an ARSCNView running face tracking. While `lensOn` is true,
/// a small semi-transparent blue-tinted disc is pinned to each eye so the
/// user sees, live in the mirror, what the Blue Tint lens looks like on
/// their own eyes. Requires a device with a TrueDepth camera
/// (iPad Pro / iPhone with Face ID) — this will NOT run in Simulator.
struct ARFaceMirrorView: UIViewRepresentable {
    @Binding var lensOn: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        sceneView.delegate = context.coordinator
        sceneView.session.delegate = context.coordinator
        sceneView.scene = SCNScene()
        sceneView.automaticallyUpdatesLighting = true

        guard ARFaceTrackingConfiguration.isSupported else {
            assertionFailure("This device has no TrueDepth camera — face tracking unsupported.")
            return sceneView
        }
        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = true
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        context.coordinator.lensOn = lensOn
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var parent: ARFaceMirrorView
        var lensOn: Bool = false {
            didSet { updateVisibility() }
        }

        // The two tint nodes, one per eye, kept alive across frames.
        private var leftTint: SCNNode?
        private var rightTint: SCNNode?

        init(_ parent: ARFaceMirrorView) {
            self.parent = parent
        }

        // Called once when the face anchor first appears — build the eye nodes.
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            guard anchor is ARFaceAnchor else { return nil }
            let faceNode = SCNNode()

            let left = makeTintDisc()
            let right = makeTintDisc()
            faceNode.addChildNode(left)
            faceNode.addChildNode(right)
            leftTint = left
            rightTint = right
            updateVisibility()

            return faceNode
        }

        // Called every frame — move the discs to the tracked eye transforms.
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }

            // ARKit gives us the eyes' full transforms directly, relative to the face anchor.
            leftTint?.simdTransform = faceAnchor.leftEyeTransform
            rightTint?.simdTransform = faceAnchor.rightEyeTransform
        }

        private func updateVisibility() {
            leftTint?.isHidden = !lensOn
            rightTint?.isHidden = !lensOn
        }

        /// A small flat, semi-transparent disc sized roughly to an iris,
        /// nudged slightly in front of the eye so it doesn't z-fight with the face mesh.
        private func makeTintDisc() -> SCNNode {
            let disc = SCNCylinder(radius: 0.0055, height: 0.0005) // ~11mm iris-sized disc
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(red: 0.35, green: 0.55, blue: 0.95, alpha: 0.35)
            material.emission.contents = UIColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0)
            material.emission.intensity = 0.15
            material.lightingModel = .constant
            material.writesToDepthBuffer = false
            disc.materials = [material]

            let node = SCNNode(geometry: disc)
            // Eye transform's local -Z points out of the eye; push the disc slightly forward.
            node.eulerAngles.x = .pi / 2
            node.position.z = 0.012
            node.renderingOrder = 10
            node.isHidden = true
            return node
        }
    }
}
