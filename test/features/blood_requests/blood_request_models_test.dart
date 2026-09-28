import 'package:flutter_test/flutter_test.dart';
import 'package:vitallink/core/utils/blood_compatibility.dart';
import 'package:vitallink/features/blood_requests/data/models/blood_request_model.dart';
import 'package:vitallink/features/blood_requests/data/models/pledge_model.dart';
import 'package:vitallink/features/blood_requests/domain/blood_request.dart';
import 'package:vitallink/features/blood_requests/domain/blood_request_enums.dart';
import 'package:vitallink/features/blood_requests/domain/pledge.dart';

void main() {
  group('BloodRequest', () {
    test('create() dÃ©duit les groupes compatibles, mÃªme groupe en premier', () {
      final r = BloodRequest.create(
        id: 'r1',
        requesterId: 'u1',
        city: 'Brazzaville',
        bloodGroupNeeded: BloodGroup.aNegative,
        hospitalId: 'h1',
      );
      expect(r.compatibleGroups.map((g) => g.label), ['A-', 'O-']);
      expect(r.status, RequestStatus.open);
      expect(r.isMedicallyVerified, isFalse);
    });

    test('unitsRemaining ne descend jamais sous 0', () {
      const r = BloodRequest(
        id: 'r',
        requesterId: 'u',
        city: 'c',
        bloodGroupNeeded: BloodGroup.oPositive,
        compatibleGroups: [BloodGroup.oPositive],
        hospitalId: 'h',
        unitsNeeded: 2,
        unitsPledged: 5,
      );
      expect(r.unitsRemaining, 0);
      expect(r.isFullyPledged, isTrue);
    });

    test('aller-retour Firestore conserve toutes les donnÃ©es', () {
      final original = BloodRequestModel.fromEntity(
        BloodRequest(
          id: 'r1',
          requesterId: 'u1',
          city: 'Brazzaville',
          bloodGroupNeeded: BloodGroup.abNegative,
          compatibleGroups: BloodCompatibility.notificationPriorityFor(
            BloodGroup.abNegative,
          ),
          hospitalId: 'h1',
          hospitalDepartment: 'MaternitÃ©',
          isMedicallyVerified: true,
          urgency: UrgencyLevel.critical,
          unitsNeeded: 3,
          unitsPledged: 1,
          notes: 'Urgent',
          createdAt: DateTime.utc(2026, 9, 28, 10),
        ),
      );

      final copy = BloodRequestModel.fromMap('r1', original.toFirestore());

      expect(copy.bloodGroupNeeded, BloodGroup.abNegative);
      expect(copy.compatibleGroups, original.compatibleGroups);
      expect(copy.hospitalDepartment, 'MaternitÃ©');
      expect(copy.isMedicallyVerified, isTrue);
      expect(copy.urgency, UrgencyLevel.critical);
      expect(copy.unitsNeeded, 3);
      expect(copy.unitsPledged, 1);
      expect(copy.createdAt, DateTime.utc(2026, 9, 28, 10));
    });

    test("la partie publique ne contient ni nom de patient ni tÃ©lÃ©phone", () {
      final map = BloodRequestModel.fromEntity(
        BloodRequest(
          id: 'r1',
          requesterId: 'u1',
          city: 'c',
          bloodGroupNeeded: BloodGroup.oPositive,
          compatibleGroups: const [BloodGroup.oPositive],
          hospitalId: 'h',
          createdAt: DateTime.utc(2026),
        ),
      ).toFirestore();
      expect(map.containsKey('patient_name'), isFalse);
      expect(map.containsKey('contact_phone'), isFalse);
    });

    test('valeurs inconnues : statut fermÃ©, groupe invalide rejetÃ©', () {
      expect(RequestStatus.fromWire('???'), RequestStatus.closed);
      expect(
        () => BloodRequestModel.fromMap('r', {
          'requester_id': 'u',
          'city': 'c',
          'blood_group_needed': 'Z+',
          'hospital_id': 'h',
        }),
        throwsFormatException,
      );
    });
  });

  group('Pledge', () {
    test('id dÃ©terministe : un seul engagement par donneur et par alerte', () {
      expect(Pledge.buildId(requestId: 'r1', donorId: 'd1'), 'r1_d1');
    });

    test('aller-retour Firestore', () {
      final model = PledgeModel(
        id: 'r1_d1',
        requestId: 'r1',
        donorId: 'd1',
        estimatedArrival: ArrivalEstimate.in30Minutes,
        status: PledgeStatus.committed,
        createdAt: DateTime.utc(2026, 9, 28, 11),
      );
      final copy = PledgeModel.fromMap('r1_d1', model.toFirestore());
      expect(copy.estimatedArrival, ArrivalEstimate.in30Minutes);
      expect(copy.status, PledgeStatus.committed);
      expect(copy.isActive, isTrue);
      expect(copy.createdAt, DateTime.utc(2026, 9, 28, 11));
    });

    test('un engagement annulÃ© est inactif', () {
      expect(PledgeStatus.fromWire('CANCELLED'), PledgeStatus.cancelled);
      expect(
        const Pledge(
          id: 'i',
          requestId: 'r',
          donorId: 'd',
          estimatedArrival: ArrivalEstimate.in1Hour,
          status: PledgeStatus.cancelled,
        ).isActive,
        isFalse,
      );
    });
  });
}
